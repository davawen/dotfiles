if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fzf_fd_opts --hidden

fenv source "$HOME/xdg_home.sh"

set -gx NVM_DIR "$XDG_DATA_HOME/nvm"
fenv source $NVM_DIR/nvm.sh
alias nvm='fenv source $NVM_DIR/nvm.sh; nvm'

for f in $HOME/.config/shell/*
	fenv source $f
end

set -g prjdir "/mnt/Projects"

set -gx QT_QPA_PLATFORMTHEME "gtk2"

set -gx PATH "$PATH:$HOME/.local/bin:$(npm config get prefix)/bin:$HOME/.local/share/cargo/bin/:/usr/local/cuda-11.7/bin:/usr/sbin:/usr/share/sbin:$DENO_INSTALL/bin"

set -gx TASKDDATA /var/taskd

set -gx MANPAGER 'nvim +Man!'
set -gx MANWIDTH 999
set -gx PAGER 'less -R'

set -gx EDITOR 'nvim'
set -gx VISUAL 'nvim'

set -gx CXX "$(which 'g++')"

set -g WPREFIXES "$HOME/.local/share/wineprefixes"

alias e=$EDITOR
alias :q='exit' # Too much vim in my fingers

alias nh='sudo nethogs'
alias py='python3'
alias node='node --experimental-fetch'
alias icat="kitty +kitten icat"
alias suod='sudo'

alias cat='bat -pp'
alias less='bat'

alias ls='lsd'
alias l='lsd -la'

alias update-grub='sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"'
alias install='sudo dnf install'

alias pls='sudo $(fc -ln -1)'
alias spindown='sudo hdparm -y /dev/disk/by-id/ata-WDC_WD5000AAKS-60Z1A0_WD-WCAWF8270723'

alias clone='git clone --depth 1'
alias ytdl='yt-dlp'
alias xclipc='xclip -selection clipboard'

