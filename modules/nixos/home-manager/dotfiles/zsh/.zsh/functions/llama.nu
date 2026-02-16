################################################################################
# llama.cpp Service Helpers (Nushell)
################################################################################

def llm-service-name [] { "llama-cpp.service" }

def llm-models-dir [] { "/var/lib/llama-cpp/models" }

def llm-base-url [] { "http://127.0.0.1:11434" }

def llm-model-aliases [] {
    {
        mistral: "mistralai_Mistral-Small-3.2-24B-Instruct-2506-Q6_K.gguf"
    }
}

def llm-default-model-name [] { "mistral" }

def llm-normalize-model-name [name: string] {
    let normalized = ($name | str trim | str downcase)
    if ($normalized | str ends-with ".gguf") {
        $normalized | str replace -r '\.gguf$' ''
    } else {
        $normalized
    }
}

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
    llm-resolve-model (llm-default-model-name)
}

def llm-resolve-model [requested: string] {
    let trimmed = ($requested | str trim)
    if (($trimmed | str length) == 0) {
        error make { msg: "Model name cannot be empty." }
    }

    let models = (llm-query-models)
    if ($models | is-empty) {
        error make { msg: "No models available. Use `llm download <url>` and `llm restart` first." }
    }

    let aliases = (llm-model-aliases)
    let target = ($aliases | get -o $trimmed | default $trimmed)
    let target_norm = (llm-normalize-model-name $target)
    let requested_norm = (llm-normalize-model-name $trimmed)

    let exact = (
        $models
        | where { |model| ((llm-normalize-model-name ($model.id | into string)) == $target_norm) }
        | get -o 0.id
    )
    if $exact != null {
        return $exact
    }

    let fuzzy = (
        $models
        | where { |model|
            let id_norm = (llm-normalize-model-name ($model.id | into string))
            ($id_norm | str contains $target_norm) or ($id_norm | str contains $requested_norm)
        }
        | get -o 0.id
    )
    if $fuzzy != null {
        return $fuzzy
    }

    let available = ($models | get id | str join ", ")
    error make {
        msg: $"Model `($trimmed)` not found. Available models: ($available)"
    }
}

def llm [] {
    print "llm usage:"
    print "  llm start                 Start llama-cpp.service"
    print "  llm stop                  Stop llama-cpp.service"
    print "  llm restart               Restart llama-cpp.service"
    print "  llm download <url>        Download a GGUF model"
    print "  llm list                  List models exposed by llama.cpp API"
    print "  llm message <text>        Send message (default model alias: mistral)"
    print "  llm logs                  Show recent llama-cpp logs"
    print "  llm logs --follow         Follow llama-cpp logs"
    print "  mistral <text>            Shortcut for `llm message --model mistral`"
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
    let aliases = (llm-model-aliases)
    let default_name = (llm-default-model-name)

    llm-query-models
    | each { |model|
        let model_id = ($model | get -o id | default "")
        let matched_alias = (
            $aliases
            | transpose alias target
            | where { |row|
                (llm-normalize-model-name $row.target) == (llm-normalize-model-name $model_id)
            }
            | get -o 0.alias
            | default ""
        )

        {
            id: $model_id
            alias: $matched_alias
            default: ($matched_alias == $default_name)
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

    let selected_model = if $model == null { llm-default-model } else { llm-resolve-model $model }
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

def mistral [
    message: string
    --system (-s): string
    --raw (-r)
] {
    if $system == null {
        if $raw {
            llm message --model mistral --raw $message
        } else {
            llm message --model mistral $message
        }
    } else {
        if $raw {
            llm message --model mistral --system $system --raw $message
        } else {
            llm message --model mistral --system $system $message
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
