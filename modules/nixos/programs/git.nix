{
  pkgs,
  user,
  ...
}:
let
  mkCommitAlias = type: ''
    !a() {
    local _scope _attention _message _prefix
    while [ $# -ne 0 ]; do
    case $1 in
      -s | --scope )
        if [ -z "$2" ]; then
          echo "Missing scope!"
          return 1
        fi
        _scope="$2"
        shift 2
        ;;
      -a | --attention )
        _attention="!"
        shift 1
        ;;
      * )
        _message="$_message $1"
        shift 1
        ;;
    esac
    done

    if [ -n "$_scope" ]; then
      _prefix="${type}($_scope)$_attention:"
    else
      _prefix="${type}$_attention:"
    fi

    git commit -m "$_prefix$_message"
    }; a
  '';
in
{
  home-manager.users.${user}.programs.git = {
    enable = true;
    settings = {
      alias = {
        amend = "commit --amend";
        build = mkCommitAlias "build";
        chore = mkCommitAlias "chore";
        ci = mkCommitAlias "ci";
        ddiff = "-c diff.external=difft diff";
        dft = "-c diff.external=difft diff";
        dl = "-c diff.external=difft log -p --ext-diff";
        dlog = "-c diff.external=difft log --ext-diff";
        docs = mkCommitAlias "docs";
        dshow = "-c diff.external=difft show --ext-diff";
        ds = "-c diff.external=difft show --ext-diff";
        feat = mkCommitAlias "feat";
        fix = mkCommitAlias "fix";
        last = "log -1 HEAD";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        perf = mkCommitAlias "perf";
        refactor = mkCommitAlias "refactor";
        rev = mkCommitAlias "revert";
        style = mkCommitAlias "style";
        test = mkCommitAlias "test";
        unstage = "reset HEAD --";
        wip = mkCommitAlias "wip";
      };

      color.ui = "auto";

      commit.gpgSign = true;

      core = {
        commitGraph = true;
        excludesfile = "~/.gitignore";
        fsmonitor = true;
        untrackedcache = true;
      };

      diff.external = "difft";

      feature.manyFiles = true;
      fetch.writeCommitGraph = true;

      "filter \"lfs\"" = {
        clean = "git-lfs clean -- %f";
        process = "git-lfs filter-process";
        required = true;
        smudge = "git-lfs smudge -- %f";
      };

      gc.writeCommitGraph = true;
      github.user = "rbright";

      gpg.format = "ssh";

      "gpg \"ssh\"" = {
        allowedSignersFile = "";
        defaultKeyCommand = "sh -c 'k=$(ssh-add -L 2>/dev/null | sed -n 1p); [ -n \"$k\" ] && printf \"key::%s\\n\" \"$k\"'";
        program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      };

      init.defaultBranch = "main";
      merge.tool = "code";

      mergetool = {
        keepBackup = false;
        prompt = false;
      };

      push.default = "current";

      tag.forceSignAnnotated = false;

      user = {
        email = "ryan@moonriseconsulting.io";
        name = "Ryan Bright";
      };
    };
  };
}
