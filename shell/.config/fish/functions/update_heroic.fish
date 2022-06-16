function update_heroic
	wget -qO- "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/latest.yml" | shyaml get-value path | grep -oP '(\d*\.)*' | awk '{printf "sudo dnf update -y "}{printf "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/"}{print "heroic-"$1"x86_64.rpm"}' | sh
end
