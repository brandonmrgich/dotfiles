# shellcheck shell=bash
# ai.zsh — ai integration

# -----------------------------
# AI coding environment (Ollama App)
# -----------------------------

export AIDER_NO_AUTO_WARNINGS=1
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_MODEL="qwen2.5-coder:7b"

# Aider config
export AIDER_AUTO_COMMITS=1
export AIDER_STREAM=1
export AIDER_EDITOR=vim

ai-on() {
    open -ga Ollama
    sleep 2
}

ai-off() {
    pkill -f Ollama
}

ai() {
    ai-guard || return 1

    ai-on

    curl -s http://localhost:11434/api/tags >/dev/null || {
        echo "Ollama not responding"
        return 1
    }

    local mode="$1"
    shift

    case "$mode" in
    patch)
        ai-patch "$@"
        ;;
    *)
        # default intelligent mode (your current behavior)
        local file_hint=""
        if [[ -n "$mode" && -z "$2" ]]; then
            file_hint="$(git ls-files | grep -Ei "$mode" | head -n 10)"
        fi

        aider \
            --model "$AIDER_MODEL" \
            --git \
            --auto-commits \
            --pretty \
            --stream \
            --subtree-only \
            --message "Relevant files:
$file_hint

Task:
$*"
        ;;
    esac
}

ait() {
    ai-on
    ai-guard || return 1

    curl -s http://localhost:11434/api/tags >/dev/null || {
        echo "Ollama not responding"
        return 1
    }

    local prompt="$*"

    local files
    files="$(git ls-files | grep -Ei "$(echo "$prompt" | tr '[:space:]' '|')" | head -n 12)"

    aider \
        --model "$AIDER_MODEL" \
        --git \
        --auto-commits \
        --message "You are working in a TypeScript/Node monorepo.

Task:
$prompt

Likely relevant files:
$files

Rules:
- Only modify files that are necessary
- Prefer minimal diffs
- Do not refactor unrelated code"
}

ai-plan() {
    local prompt="$*"

    echo "=== AI PLAN ==="
    echo "$prompt"
    echo ""

    echo "Top candidate files:"
    ai-files "$(echo "$prompt" | tr '[:space:]' '|')"

    echo ""
    echo "Suggested scope:"
    echo "- minimal diff"
    echo "- touch only ranked files"
    echo ""
}

# -----------------------------
# Safety mode (production guardrails)
# -----------------------------

export AI_SAFE_MODE=1

ai-safe() {
    AI_SAFE_MODE=1 ai "$@"
}

ai-unsafe() {
    AI_SAFE_MODE=0 ai "$@"
}

ai-guard() {
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "⚠️ Uncommitted changes detected"
        git status -s
        echo ""
        echo "Abort recommended before AI edits."
        return 1
    fi
}

# -----------------------------
# Interactive file selection (Claude-style context picker)
# -----------------------------

ai-select-files() {
    git ls-files | fzf -m --preview 'head -n 40 {}'
}

# -----------------------------
# AI file selection heuristics (Claude-like context shaping)
# -----------------------------

ai-files() {
    local query="$1"

    git ls-files |
        awk -v q="$query" '
            BEGIN { q=tolower(q) }
            {
                score=0
                file=tolower($0)

                if (file ~ q) score+=10
                if (file ~ /test|spec/) score+=2
                if (file ~ /route|api|controller/) score+=3
                if (file ~ /util|helper/) score+=1

                print score, $0
            }' |
        sort -nr -k1,1 |
        cut -d' ' -f2-
}

ai-patch() {
    ai-on
    ai-guard || return 1

    aider \
        --model "$AIDER_MODEL" \
        --git \
        --diff \
        --message "You are in PATCH MODE.

Rules:
- Output only minimal diffs
- No refactors unless required
- Prefer smallest possible change
- Do not modify unrelated code

Task:
$*"
}

# -----------------------------
# Repo context control (monorepo-safe)
# -----------------------------
ai-root() {
    git rev-parse --show-toplevel 2>/dev/null
}

ai-cd() {
    cd "$(ai-root)" || return 1
}

ai-context() {
    ai-guard || return 1

    local files="$*"

    aider \
        --model "$AIDER_MODEL" \
        --git \
        --auto-commits \
        --pretty \
        --stream \
        --message "Working on selected files:

$files

Task:
(read next prompt interactively)"
}
