# Lines configured by zsh-newuser-install
# Save ALL the commands
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e
bindkey "\eOD" backward-word
bindkey "\eOC" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[5~" history-search-backward
bindkey "\e[6~" history-search-forward

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/zigdon/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

setopt auto_list            ## Automatically list choices on completion
setopt auto_menu            ## perform menu completion on subsequent completes
setopt auto_pushd           ## Make cd push the owd to the stac
setopt auto_remove_slash    ## Remove trailing / when it was added by completion
setopt inc_append_history   ## Append history lines as they are executed, not only on exit
setopt interactive_comments ## allow comments on command line
setopt listambiguous        ## autolists second completions if 1st ambiguous
setopt list_ambiguous       ## List options even if we can complete some prefix first
setopt list_types           ## show file types when completing
setopt noclobber            ## don't allow > and >> to overwrite existing files
setopt no_hup               ## don't hangup jobs on exit
setopt no_list_beep         ## don't beep ambiguous completions
setopt notify               ## Report status of background jobs immediately
setopt print_exit_value     ## Print non-zero exit status
setopt pushd_ignore_dups    ## Don't push multiple copies of the same directory
setopt rm_star_wait         ## Force a pause before allowing an answer on rm *
setopt transient_rprompt    ## Remove the right-side prompt if the cursor comes close
unsetopt nomatch            ## Pass unmatched wildcards as arguments

## let's try vi mode
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

if [[ -f ~/.bash_aliases ]]; then
  . ~/.bash_aliases
fi

if [[ -f ~/.bash_environment ]]; then
  . ~/.bash_environment
fi

# automatically log out of a console vterm after 10 minutes of inactivity
if test -z "$DISPLAY"; then
  echo Auto-logout after 10 minutes of idle time. Unset TMOUT to disable.
  TMOUT=600
fi

## Watch for login/logouts
watch=(all)
LOGCHECK=300  # check every 5 min for login/logout activity
WATCHFMT='%D %T %l  %n %a from %m'

# enable command completion for blaze
#cache-path must exist
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

P4DIFF=vimdiff

## use less as the pager for the "< file" shorthand
READNULLCMD="less"

# set prompt, color based on LOAS access.
default_prompt () {
  PS1="%m%(#.#.$) "
  RPS1=" %~"
}

RED="%{[31m%}"
YELLOW="%{[33m%}"
GREEN="%{[32m%}"
NORMAL="%{[0m%}"

# for git branch
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       '%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git cvs svn

# use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del "
  fi
}

RPROMPT='[$(vcs_info_wrapper)${YELLOW}%d${NORMAL}]'

# shortcut fuctions
function pyhelp () { python -c "help($*)" }
function rand () { A=($*); let "R=$RANDOM % $#A"; echo $A[R+1] }

if [[ -f ~/.dotfiles/zshrc ]]; then
  . ~/.dotfiles/zshrc
fi

