# dotfiles

portable shell + tooling setup for a linux workstation. distro-agnostic via
homebrew-on-linux, deployed with gnu stow.

## layout

each top-level directory is a stow *package* whose contents mirror `$HOME`:

| package     | deploys to                      |
|-------------|---------------------------------|
| `zsh`       | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `git`       | `~/.gitconfig`, `~/.gitignore`  |
| `starship`  | `~/.config/starship.toml`       |

`Brewfile` is the single source of truth for installed tooling.
`bootstrap.sh` ties it all together.

## fresh machine

```sh
git clone <this-repo> ~/dotfiles
sh ~/dotfiles/bootstrap.sh
```

then, per-machine (these are gitignored, never committed):

- `~/.gitconfig.local` — your git identity (email, name, signingkey)
- `~/.zshrc.local` — optional machine-local shell overrides

## adding a dotfile later

drop it into the matching package mirroring its `$HOME` path, then re-stow:

```sh
cd ~/dotfiles && stow --restow zsh git starship
```

## what is deliberately NOT here

secrets and per-machine identity: ssh keys, signing keys, tokens, and
`*.local` files. these are gitignored. regenerate ssh/signing keys on each new
machine and rebuild `~/.ssh/allowed_signers`.
