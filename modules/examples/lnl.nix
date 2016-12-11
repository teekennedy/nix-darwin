{ config, lib, pkgs, ... }:
{
  environment.systemPackages =
    [ config.system.build.nix

      pkgs.lnl.zsh
      pkgs.lnl.tmux
      pkgs.lnl.vim
      pkgs.curl
      pkgs.fzf
      pkgs.gettext
      pkgs.git
      pkgs.jq
      pkgs.silver-searcher

      pkgs.nix-repl
      pkgs.nox
    ];

  services.nix-daemon.enable = true;
  services.nix-daemon.tempDir = "/nix/tmp";

  services.activate-system.enable = true;

  system.defaults.global.InitialKeyRepeat = 10;
  system.defaults.global.KeyRepeat = 1;

  programs.tmux.loginShell = "${pkgs.lnl.zsh}/bin/zsh -l";
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableFzf = true;
  programs.tmux.enableVim = true;

  programs.tmux.tmuxConfig = ''
    bind 0 set status

    set -g status-bg black
    set -g status-fg white
  '';

  environment.variables.EDITOR = "vim";
  environment.variables.HOMEBREW_CASK_OPTS = "--appdir=/Applications/cask";

  environment.variables.SHELL = "${pkgs.lnl.zsh}/bin/zsh";

  environment.variables.GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  environment.variables.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  environment.shellAliases.l = "ls -lh";
  environment.shellAliases.ls = "ls -G";
  environment.shellAliases.g = "git log  --oneline --max-count 42";
  environment.shellAliases.gl = "git log --graph --oneline";
  environment.shellAliases.gd = "git diff --minimal --patch";

  environment.etc."zprofile".text = ''
    # /etc/zprofile: DO NOT EDIT -- this file has been generated automatically.
    # This file is read for login shells.

    # Only execute this file once per shell.
    if [ -n "$__ETC_ZPROFILE_SOURCED" ]; then return; fi
    __ETC_ZPROFILE_SOURCED=1

    autoload -U promptinit && promptinit
    PROMPT='%B%(?..%? )%b⇒ '
    RPROMPT='%F{green}%~%f'

    bindkey -e
    setopt autocd

    autoload -U compinit && compinit

    nix () {
      cmd=$1
      shift

      case $cmd in
        'b'|'build')        nix-build --no-out-link -E "with import <nixpkgs> {}; $@" ;;
        'e'|'eval')         nix-instantiate --eval -E "with import  <nixpkgs> {}; $@" ;;
        'i'|'instantiate')  nix-instantiate -E "with import <nixpkgs> {}; $@" ;;
        'r'|'repl')         nix-repl '<nixpkgs>' ;;
        's'|'shell')        nix-shell -E "with import <nixpkgs> {}; $@" ;;
        'p'|'package')      nix-shell '<nixpkgs>' -p "with import <nixpkgs> {}; $@" --run $SHELL ;;
        'z'|'zsh')          nix-shell '<nixpkgs>' -E "with import <nixpkgs> {}; $@" --run $SHELL ;;
        'exec')
          echo "reexecuting shell: $SHELL" >&2
          __ETC_ZSHRC_SOURCED= \
          __ETC_ZSHENV_SOURCED= \
          __ETC_ZPROFILE_SOURCED= \
            exec $SHELL -l
          ;;
      esac
    }

    conf=$HOME/.nixpkgs/darwin-config.nix
    pkgs=$HOME/.nix-defexpr/nixpkgs

    # Read system-wide modifications.
    if test -f /etc/zprofile.local; then
      . /etc/zprofile.local
    fi
  '';

  environment.etc."zshenv".text = ''
    # /etc/zshenv: DO NOT EDIT -- this file has been generated automatically.
    # This file is read for all shells.

    # Only execute this file once per shell.
    # But don't clobber the environment of interactive non-login children!

    if [ -n "$__ETC_ZSHENV_SOURCED" ]; then return; fi
    export __ETC_ZSHENV_SOURCED=1

    export NIX_PATH=nixpkgs=$HOME/.nix-defexpr/nixpkgs:darwin=$HOME/.nix-defexpr/darwin:darwin-config=$HOME/.nixpkgs/darwin-config.nix:$HOME/.nix-defexpr/channels_root

    # Set up secure multi-user builds: non-root users build through the
    # Nix daemon.
    if [ "$USER" != root -a ! -w /nix/var/nix/db ]; then
        export NIX_REMOTE=daemon
    fi

    # Read system-wide modifications.
    if test -f /etc/zshenv.local; then
      . /etc/zshenv.local
    fi
  '';

  environment.etc."zshrc".text = ''
    # /etc/zshrc: DO NOT EDIT -- this file has been generated automatically.
    # This file is read for interactive shells.

    # Only execute this file once per shell.
    if [ -n "$__ETC_ZSHRC_SOURCED" -o -n "$NOSYSZSHRC" ]; then return; fi
    __ETC_ZSHRC_SOURCED=1

    # history defaults
    SAVEHIST=2000
    HISTSIZE=2000
    HISTFILE=$HOME/.zsh_history

    setopt HIST_IGNORE_DUPS SHARE_HISTORY HIST_FCNTL_LOCK

    export PATH=${config.environment.systemPath}''${PATH:+:$PATH}
    typeset -U PATH

    ${config.system.build.setEnvironment}
    ${config.system.build.setAliases}

    # Read system-wide modifications.
    if test -f /etc/zshrc.local; then
      . /etc/zshrc.local
    fi
  '';
}
