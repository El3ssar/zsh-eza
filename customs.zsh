# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# El3ssar customs, sourced at the end of zsh-eza.plugin.zsh.
#
# Replaces upstream's aliases with functions that:
#   - use my default params (icons, hyperlinks, forced colour)
#   - page the output through `ov` (or `less`) only when it does not fit
#     the terminal and no arguments were given
#
# Kept in its own file so rebasing onto upstream rarely conflicts.

[[ $TERM == 'dumb' ]] && return 0
(( $+commands[eza] )) || return 0

() {
  builtin emulate -L zsh

  # `zstyle ':zsh-eza:config' user-params ...` still wins over these defaults.
  local style
  if ! zstyle -s ':zsh-eza:config' user-params style; then
    _zsh_eza_params=(
      '--git' '--icons=always' '--group' '--group-directories-first'
      '--time-style=long-iso' '--color-scale=all' '--color=always' '--hyperlink=always'
    )
    zstyle -s ':zsh-eza:config' extra-params style && _zsh_eza_params+=( ${(z)style} )
  fi
}

# Usage: _zsh_eza_list <eza flags...> -- <user args...>
_zsh_eza_list() {
  builtin emulate -L zsh
  local -i sep=${@[(i)--]}
  local -a flags=( "${@[1,sep-1]}" ) args=( "${@[sep+1,-1]}" )

  if (( ${#args} )); then
    COLUMNS=$COLUMNS command eza "${flags[@]}" "${_zsh_eza_params[@]}" "${args[@]}"
    return
  fi

  local out
  out=$(COLUMNS=$COLUMNS command eza "${flags[@]}" "${_zsh_eza_params[@]}") || return
  local -a lines=( "${(@f)out}" )
  if (( ${#lines} > LINES )); then
    if (( $+commands[ov] )); then
      print -r -- "$out" | ov --quit-if-one-screen
    else
      print -r -- "$out" | less -RFX
    fi
  else
    print -r -- "$out"
  fi
}

builtin unalias ls l ll llm la lx lt tree 2>/dev/null

function ls   { _zsh_eza_list -- "$@" }
function l    { _zsh_eza_list --git-ignore -- "$@" }
function ll   { _zsh_eza_list --all --header --long -- "$@" }
function llm  { _zsh_eza_list --all --header --long --sort=modified -- "$@" }
function la   { _zsh_eza_list -a -- "$@" }
function lx   { _zsh_eza_list -lbhHigUmuSa@ -- "$@" }
function lt   { _zsh_eza_list --tree -- "$@" }
function tree { _zsh_eza_list --tree -- "$@" }
