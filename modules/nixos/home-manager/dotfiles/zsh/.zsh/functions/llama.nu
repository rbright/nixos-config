################################################################################
# llama.cpp Service Helpers (Nushell)
################################################################################

def llm-service-name [] { "llama-cpp.service" }

def llm-models-dir [] { "/var/lib/llama-cpp/models" }

def llm-base-url [] { "http://127.0.0.1:11434" }

def llm-require [command: string] {
    if (which $command | is-empty) {
        error make { msg: $"($command) is not available on PATH" }
    }
}

def llm-run-systemctl [action: string] {
    llm-require "systemctl"
    let service = (llm-service-name)

    if ((^id -u | str trim) == "0") {
        ^systemctl $action $service
    } else {
        ^sudo systemctl $action $service
    }
}

def llm-query-models [] {
    llm-require "curl"

    let url = $"(llm-base-url)/v1/models"
    try {
        ^curl --silent --show-error --fail $url | from json | get data
    } catch { |err|
        error make { msg: $"Failed to query models from ($url): ($err.msg)" }
    }
}

def llm-default-model [] {
    let models = (llm-query-models)
    if ($models | is-empty) {
        error make { msg: "No models available. Use `llm download <url>` first." }
    }

    $models | get 0.id
}

def llm [] {
    print "llm usage:"
    print "  llm start                 Start llama-cpp.service"
    print "  llm stop                  Stop llama-cpp.service"
    print "  llm restart               Restart llama-cpp.service"
    print "  llm download <url>        Download a GGUF model"
    print "  llm list                  List models exposed by llama.cpp API"
    print "  llm message <text>        Send plaintext message to /v1/chat/completions"
    print "  llm logs                  Show recent llama-cpp logs"
    print "  llm logs --follow         Follow llama-cpp logs"
}

def "llm start" [] {
    llm-run-systemctl "start"
}

def "llm stop" [] {
    llm-run-systemctl "stop"
}

def "llm restart" [] {
    llm-run-systemctl "restart"
}

def "llm download" [
    url: string
    --name (-n): string
] {
    llm-require "curl"
    llm-require "install"

    let inferred_name = (
        $url
        | split row "/"
        | last
        | split row "?"
        | first
    )
    let filename = if $name == null { $inferred_name } else { $name }

    if (($filename | str trim | str length) == 0) {
        error make { msg: "Could not infer filename from URL. Pass --name <file.gguf>." }
    }

    let models_dir = (llm-models-dir)
    let target = ($models_dir | path join $filename)

    print $"(ansi blue)Downloading model to ($target)(ansi reset)"
    if ((^id -u | str trim) == "0") {
        ^install -d -m 0755 $models_dir
        ^curl --location --fail --show-error $url --output $target
    } else {
        ^sudo install -d -m 0755 $models_dir
        ^sudo curl --location --fail --show-error $url --output $target
    }

    if not (($filename | str downcase) | str ends-with ".gguf") {
        print $"(ansi yellow)Warning: file extension is not .gguf: ($filename)(ansi reset)"
    }

    print $"(ansi green)Model downloaded: ($target)(ansi reset)"
    print $"(ansi yellow)Run `llm restart` to load newly downloaded models.(ansi reset)"
}

def "llm list" [] {
    llm-query-models
    | each { |model|
        {
            id: ($model | get -o id | default "")
            owned_by: ($model | get -o owned_by | default "")
            object: ($model | get -o object | default "")
        }
    }
}

def "llm message" [
    message: string
    --model (-m): string
    --system (-s): string
    --raw (-r)
] {
    llm-require "curl"

    let selected_model = if $model == null { llm-default-model } else { $model }
    let has_system = (($system | default "" | str trim | str length) > 0)

    let payload = {
        model: $selected_model
        messages: (
            if $has_system {
                [
                    { role: "system", content: $system }
                    { role: "user", content: $message }
                ]
            } else {
                [{ role: "user", content: $message }]
            }
        )
    }

    let response = (try {
        ^curl --silent --show-error --fail $"(llm-base-url)/v1/chat/completions" -H "Content-Type: application/json" -d ($payload | to json) | from json
    } catch { |err|
        error make { msg: $"Chat request failed: ($err.msg)" }
    })

    if $raw {
        $response
    } else {
        let content = ($response | get -o choices.0.message.content)
        if $content == null {
            $response
        } else {
            $content
        }
    }
}

def "llm logs" [
    --follow (-f)
    --lines (-n): int
] {
    llm-require "journalctl"
    let service = (llm-service-name)
    let lines = ($lines | default 200)

    if ((^id -u | str trim) == "0") {
        if $follow {
            ^journalctl -u $service -f
        } else {
            ^journalctl -u $service -n $lines --no-pager
        }
    } else {
        if $follow {
            ^sudo journalctl -u $service -f
        } else {
            ^sudo journalctl -u $service -n $lines --no-pager
        }
    }
}
