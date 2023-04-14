if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fzf_fd_opts --hidden
set -g theme_color_scheme terminal

fenv source "$HOME/xdg_home.sh"

for f in $HOME/.config/shell/*
	fenv source $f
end

set -g prjdir "/mnt/Projects"

set -gx LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/opt/rocm/lib:/opt/rocm/lib64"
set -gx PATH "$PATH:$HOME/.local/bin:$(npm config get prefix)/bin:$(yarn global bin):$HOME/.local/share/cargo/bin/:/usr/local/cuda/bin:/usr/sbin:/usr/share/sbin:$DENO_INSTALL/bin:/opt/rocm/bin:/opt/rocm/opencl/bin:$HOME/.local/share/go/bin"
set -gx LS_COLORS "ow=36:"

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
alias icat="kitty +kitten icat"
alias suod='sudo'

alias cat='bat -pp'
alias less='bat'

alias ls='lsd'
alias l='lsd -la'

alias update-grub='sudo grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.conf)"'

abbr dinstall "sudo dnf install"
abbr dupdate "sudo dnf update"
abbr dsearch "dnf search -C"
abbr dprovides "dnf provides -C"
abbr dlist "dnf list -C"

abbr clang20 "clang++ -std=c++20"

alias pls='sudo $(fc -ln -1)'
alias spindown='sudo hdparm -y /dev/disk/by-id/ata-WDC_WD5000AAKS-60Z1A0_WD-WCAWF8270723'

alias clone='git clone --depth 1'
alias ytdl='yt-dlp'
alias xclipc='xclip -selection clipboard'

# Starship
starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/davawen/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
