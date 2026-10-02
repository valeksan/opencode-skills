git_prompt() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        local dirty="○"; [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="●"
        local ahead=""
        if git rev-parse @{u} >/dev/null 2>&1; then
            ahead=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null | awk '{printf " ↑%s ↓%s", $1, $2}')
        fi
        echo -e " \[\e[38;5;51m\](git:\[\e[38;5;45m\]${branch}\[\e[38;5;207m\]${dirty}\[\e[38;5;39m\]${ahead}\[\e[38;5;51m\])"
    fi
}
PS1='\n\[\e[38;5;45m\]╭─\[\e[38;5;51m\]\u\[\e[38;5;39m\]@\[\e[38;5;45m\]\h \[\e[38;5;33m\]\w\[$(git_prompt)\]\n\[\e[38;5;45m\]╰─\[\e[38;5;51m\]❯\[\e[0m\] '
