if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fzf_fd_opts --hidden
set -g theme_color_scheme terminal

fenv source "$HOME/xdg_home.sh"

set -g prjdir "/mnt/Projects"

set -gx LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/opt/rocm/lib:/opt/rocm/lib64"

function add_path
	if not string match -q -- "$argv" $PATH
	  set -gx PATH $PATH "$argv" 
	end
end

set -gx PNPM_HOME "/home/davawen/.local/share/pnpm"
set --export BUN_INSTALL "$HOME/.bun"

add_path "$PNPM_HOME"
add_path "$BUN_INSTALL/bin"
add_path "$HOME/.local/bin"
if type -q npm
	add_path "$(npm config get prefix)/bin"
end
if type -q yarn
	add_path "$(yarn global bin)"
end
add_path "$HOME/.local/share/cargo/bin/"
add_path "/usr/local/cuda/bin"
add_path "$DENO_INSTALL/bin"
add_path "/opt/rocm/bin"
add_path "/opt/rocm/opencl/bin"
add_path "$HOME/.local/share/go/bin"

set -gx VCPKG_ROOT "$HOME/.local/share/vcpkg/"
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

alias dnf='dnf5'

abbr dnfi "sudo dnf5 install"
abbr dnfu "sudo dnf5 upgrade"
abbr dnfs "sudo dnf5 -C search"
abbr dnfp "sudo dnf5 -C provides"
abbr dnfl "sudo dnf5 -C list"
abbr dnff "sudo dnf5 -C info"

abbr pcm "sudo pacman -S"

abbr clang20 "clang++ -std=c++20"

alias homegit="git --git-dir=$HOME/homegit/.git --work-tree=$HOME"

alias pls='sudo $(fc -ln -1)'
alias spindown='sudo hdparm -y /dev/disk/by-id/ata-WDC_WD5000AAKS-60Z1A0_WD-WCAWF8270723'

alias clone='git clone --depth 1'
alias ytdl='yt-dlp'
alias xclipc='xclip -selection clipboard'

# Starship
if type -q starship
	starship init fish | source
else
	echo "WARNING: starship is not installed"
end

# Zoxide
if type -q zoxide
	zoxide init fish | source
end
echo "UwU, ^-^" | lolcat -F 0.5
if [ "$(date +%j)" = "026" ]; printf "Happy birthday Avaine!!!\n%.0s" (seq 25) | lolcat; end;
# opam configuration
source /home/davawen/.local/share/opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
