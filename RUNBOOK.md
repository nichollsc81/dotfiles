# runbook — test the dotfiles on a throwaway wsl distro

dry-run the setup on a disposable wsl distro before trusting it on a real
machine. teardown (step 8) deletes the distro, so nothing is left behind.

## 0. push the latest changes first

the runbook clones from the remote, so anything uncommitted locally won't be
tested:

```bash
cd ~/dotfiles && git push
```

## 1. create an isolated test distro *(windows powershell / terminal)*

use a distro name you don't otherwise use, so it's trivial to nuke later.

```powershell
wsl --list --online                 # see what's available
wsl --install -d Ubuntu-24.04       # installs + launches; pick a unique one if 24.04 is in use
```

first launch prompts you to create a unix user + password. that user becomes
the default.

## 2. install prerequisites *(inside the new distro)*

homebrew needs a compiler; we also want git/zsh/gh up front to fetch the
private repo.

```bash
sudo apt update
sudo apt install -y build-essential procps curl file git zsh gh
```

## 3. authenticate to github and clone

```bash
gh auth login            # choose GitHub.com -> HTTPS -> login via browser
gh repo clone nicholls-c/dotfiles ~/dotfiles
```

## 4. run the bootstrap

```bash
sh ~/dotfiles/bootstrap.sh
```

this installs homebrew, runs `brew bundle` (the long part — installs
everything incl. `stow`), installs oh-my-zsh *keeping the stowed `.zshrc`*,
stows `zsh git starship`, installs the krew plugins, and `chsh`es you to zsh.

## 5. set your per-machine identity

the committed `.gitconfig` includes this file; it doesn't exist yet, so create
it:

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
    email = you@test.example
    name  = your name
EOF
```

skip `signingkey`/commit-signing for a throwaway box, or git will complain it
can't sign.

## 6. restart the shell so zsh is the default *(windows side)*

```powershell
wsl --shutdown
```

then reopen the distro — you should land in zsh with the starship `λ` prompt.

## 7. verify

```bash
echo $SHELL                  # .../zsh
brew --version               # brew on PATH
type k && type gs            # aliases resolve (kubectl / git status)
kubectl krew list            # cost, deprecations, sniff
readlink ~/.zshrc            # -> ~/dotfiles/zsh/.zshrc  (confirms stow symlink)
git config user.email        # your .local value
```

## 8. teardown when done *(windows side)*

```powershell
wsl --unregister Ubuntu-24.04
```

that deletes the whole test distro — clean slate, nothing left behind.

## wsl gotchas worth knowing

- **`build-essential` is non-negotiable** — homebrew's `brew bundle` will fail
  to compile bottles without it. it's the most common first-run failure.
- **clipboard helpers won't work headless.** `uuid()`, `argo_pass()` and the
  `dsh`/`dkill` aliases pipe to `xclip`, which needs wslg (the gui layer). on
  wslg-enabled win11 it's fine; on a minimal setup those clipboard pipes just
  error harmlessly. if you want wsl-native clipboard later, `clip.exe` is the
  usual swap-in.
- **`chsh` uses the system zsh** (`/usr/bin/zsh`, in `/etc/shells`) — correct,
  since there's no `zsh` formula in the brewfile. if `chsh` ever refuses, set
  the default via `/etc/wsl.conf` instead.
- **`brew bundle` is slow on first run** (lots of formulae). expect 10–20+ min
  depending on bandwidth/cpu; it's installing your entire toolchain.
