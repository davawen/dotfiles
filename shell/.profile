then
	shopt -s cdspell
fi

prjdir="/mnt/Projects"

function Proto()
{
	protoPath="$prjdir/Prototyping/$1"
	
	if [ ! -d $protoPath ]
	then
		mkdir -p $protoPath
	fi

	cd $protoPath
}

function Project()
{
	IFS=$'\n' fdArray=($(fd --base-directory $prjdir --glob $1))
	
	fdNum=${#fdArray[@]}

	if [ $fdNum -eq 0 ]
	then
		echo "No match found"
	elif [ $fdNum -eq 1 ]
	then
		cd "$prjdir/${fdArray[1]}"
	else
		ITER=1
		for i in ${fdArray[@]}
		do
			printf "%3d. %s\n" "$ITER" "$i"
			((ITER++))
		done

		printf "Choice: "
		read userInput

		cd "$prjdir/${fdArray[$userInput]}"
	fi
}

function Calc()
{
	python3 -c "print( $* )"
}

function UpdateHeroic()
{
	wget -qO- "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/latest.yml" | shyaml get-value path | grep -oP '(\d*\.)*' | awk '{printf "sudo dnf update -y "}{printf "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/"}{print "heroic-"$1"x86_64.rpm"}' | sh
}

function SyncTasks()
{
	currentDirectory=$(pwd)

	cd "$HOME/.task"

	if [[ $1 =~ p ]]
	then
		git pull
	else
		printf "Are you sure you want to sync? [y/N] "
		read
		echo 
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			git add .
			git commit -m "Sync $(date +'%F %H:%M:%S')"
			git push
			# do dangerous stuff
		fi
	fi

	cd $currentDirectory
}

function Extract()
{
	# Extract the given tar archive to a given directory

	if [ $# -eq 0 ]
	then
		echo "Usage: Extract <archive> [<directory>]"
		return 1
	fi

	if [ $# -eq 1 ]
	then
		tar -xf $1
	else
		mkdir -p $2
		tar -xf $1 -C $2
	fi
}

function Q()
{
	alias urlencode='python3 -c "import sys, urllib.parse as ul; \
    print (ul.quote_plus(sys.argv[1]))"'
	
	firefox --new-tab "https://www.google.com/search?q=$(urlencode "$*")"	
}

for f in $HOME/.config/shell/*
do
	source "$f"
done

export QT_QPA_PLATFORMTHEME="gtk2"

export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$(npm config get prefix)/bin:$HOME/.local/share/cargo/bin/:/usr/local/cuda-11.7/bin"

export TASKDDATA=/var/taskd

export MANPAGER='nvim +Man!'
export MANWIDTH=999
export PAGER='less -R'

export EDITOR='nvim'
export VISUAL='nvim'

export CXX="$(which 'g++')"

WPREFIXES="$HOME/.local/share/wineprefixes"

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
