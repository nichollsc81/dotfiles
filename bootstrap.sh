#!/usr/bin/env sh
# bootstrap a fresh linux box from this repo. safe to re-run (idempotent).
set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. homebrew (linux) — install if missing
if ! command -v brew >/dev/null 2>&1; then
    echo "==> installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 2. all tooling from the brewfile
echo "==> brew bundle"
brew bundle --file="$REPO_DIR/Brewfile"

# 3. oh-my-zsh (unattended — don't switch shell or start zsh here)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> installing oh-my-zsh"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 4. symlink dotfiles into $HOME via stow
echo "==> stowing dotfiles"
cd "$REPO_DIR"
stow --restow --target="$HOME" zsh git starship

# 5. krew plugins (krew itself comes from the brewfile)
if command -v kubectl-krew >/dev/null 2>&1 || kubectl krew version >/dev/null 2>&1; then
    kubectl krew install cost deprecations sniff || true
fi

# 6. default shell
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo "==> setting zsh as default shell"
    chsh -s "$(command -v zsh)" || echo "could not chsh automatically — run: chsh -s \$(command -v zsh)"
fi

cat <<'EOF'

done. next steps:
  1. open a new shell
  2. create ~/.gitconfig.local with your new identity, e.g.:

       [user]
           email = you@newjob.example
           name  = your name
           signingkey = ~/.ssh/id_ed25519.pub

  3. generate an ssh key, run `gh auth login`, rebuild ~/.ssh/allowed_signers
EOF
