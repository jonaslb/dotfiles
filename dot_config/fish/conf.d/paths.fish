set -x fish_user_paths $fish_user_paths $HOME/.local/bin
set -q XDG_DATA_HOME; or set -x XDG_DATA_HOME $HOME/.local/share
set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x RUSTUP_HOME $XDG_DATA_HOME/rustup
set fish_user_paths $fish_user_paths $CARGO_HOME/bin
set fish_user_paths $fish_user_paths $XDG_DATA_HOME/npm/bin
set fish_user_paths $fish_user_paths $HOME/go/bin
