#!/bin/bash
#
# Bootstrap: make sure Go is available, then run the setup program in setup/.
# Pass --keep-going to report failed steps and continue with the next ones.

set -e

cd "$(dirname "$0")"

if ! command -v go &> /dev/null; then
  case "$(uname -s)" in
  Darwin)
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew install go
    ;;
  Linux)
    # Same layout as the Go step's release install, so that step sees it as done
    case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2 && exit 1 ;;
    esac
    version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
    rm -rf "$HOME/.local/go"
    mkdir -p "$HOME/.local/go" "$HOME/.local/bin"
    curl -fsSL "https://go.dev/dl/$version.linux-$arch.tar.gz" | tar -xz -C "$HOME/.local/go" --strip-components=1
    ln -sf "$HOME/.local/go/bin/go" "$HOME/.local/bin/go"
    ln -sf "$HOME/.local/go/bin/gofmt" "$HOME/.local/bin/gofmt"
    export PATH="$HOME/.local/bin:$PATH"
    ;;
  esac
fi

exec go -C setup run . "$@"
