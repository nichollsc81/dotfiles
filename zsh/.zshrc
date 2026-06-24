# path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="apple" # apple robbyrussell

COMPLETION_WAITING_DOTS="true"

# don't mark untracked files under vcs as dirty (faster status on big repos)
DISABLE_UNTRACKED_FILES_DIRTY="true"

# add wisely, as too many plugins slow down shell startup.
plugins=(git z uv kubectl argocd azure docker helm istioctl)

source $ZSH/oh-my-zsh.sh

# user configuration

# homebrew (guarded so the shell still loads on a box without brew)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# starship
command -v starship >/dev/null && eval "$(starship init zsh)"

# python && uv
va () {
    source .venv/bin/activate 2>/dev/null || source ../.venv/bin/activate 2>/dev/null || echo 'no .env found in this or parent directory' && false
}

va! () {
    va || vc && va
}

vc () {
    uv venv --seed --python-preference managed "$@"
}

vd () { deactivate; }

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init - bash)"

# move tag
move_tag(){
    TAG=${1}

    echo -e "Removing tag: ${TAG}";
    git tag -d ${TAG};
    git push origin --delete ${TAG};

    echo -e "Retagging...";
    git tag ${TAG};
    git push origin ${TAG};
}

export PATH="$PATH:$HOME/.local/bin"

# git
alias gs="git status"
alias gc="git commit"
alias gi="git init"
alias gcl="git clone"
alias ga="git add"
alias gap="git add --patch"
alias gd="git diff"
alias gr="git restore"
alias gp="git push"
alias gu="git pull"

alias k="kubectl"
alias cls="clear"

# terraform completion (path-resolved, not pinned to a cellar version)
autoload -U +X bashcompinit && bashcompinit
command -v terraform >/dev/null && complete -o nospace -C terraform terraform

# az function
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1

# fzf
command -v fzf >/dev/null && source <(fzf --zsh)

# opencost / krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# claude
configure_claude() {
    claude mcp add --transport sse context7 https://mcp.context7.com/sse

    claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)

    claude mcp add sequential-thinking -s local -- npx -y @modelcontextprotocol/server-sequential-thinking
}
export PATH="$HOME/.bin:$PATH"

# get public ipv4
myip() {
    echo "$(wget -q -O - ipinfo.io/ip)"
}

# all resources in k8s namespaces
alias all-ns='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get -o name -n $1'

# argo admin password to clipboard
argo_pass(){
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xclip -sel clip
}

# forward argo svc
argo_fwd() {
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

alias dsh='docker exec -it $(  docker ps | fzf | awk '"'"'{print $1;}'"'"'  ) sh'
alias dbash='docker exec -it $(  docker ps | fzf | awk '"'"'{print $1;}'"'"'  ) bash'
alias dkill='docker kill $(  docker ps | fzf | awk '"'"'{print $1;}'"'"'  )'

# thefuck
command -v thefuck >/dev/null && eval $(thefuck --alias --enable-experimental-instant-mode)

# uuid
uuid() {
    python3 -c 'import uuid; print(uuid.uuid4())' | tr -d '\r\n' | xclip -selection clipboard
}

# machine-local overrides (gitignored, optional)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
