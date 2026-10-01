

#--Functions
wh() {
    sudo pkill dnsmasq ; cd $HOME/Programs/airgeddon && sudo bash airgeddon.sh ; cd
}
scode(){
    sudo codium --no-sandbox --user-data-dir=/home/masrkai/.config/VSCodium
}
sudophone(){
    adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
}


fixcode(){
    rm -rf ~/.config/VSCodium/GPUCache/
}
fixgit(){
    sudo chown -R $(whoami) .git
}
fix-arduino(){
    rm -rf ~/.config/arduino-ide/GPUCache/
}
fixbrave(){
    sudo rm -rf ~/.config/BraveSoftware/Brave-Browser/SingletonLock
}
fusb(){
        sudo chown masrkai  /dev/ttyUSB0
}
sec(){
    fwupdmgr get-devices && fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
}
fixkde(){
    sudo pkill -f plasmashell # Kill the current plasmashell process
    plasmashell --replace > /dev/null 2>&1 & disown
}




# s() {
# if [[ $# == 0 ]]; then
#     eval "sudo $(fc -ln -1)"
# else
#     sudo "$@"
# fi }

export FZF_DEFAULT_OPTS='
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'


# export HISTCONTROL="erasedups:ignoreboth"
# export HISTFILE="$HOME/.bash_history"
# export HISTORY_SIZE="1000000"


export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTFILE="$HOME/.bash_history"
export HISTCONTROL="erasedups:ignorespace"

# Append this session's history to the file on exit, instead of overwriting
shopt -s histappend



# export PS1='\[\e[36;1m\]>>>>>>Hi Masrkai!\[\e[0m\] \[\e[1m\]\w\n\e[38;5;160m\t\e[0m[\e[36m\u\e[38;5;240m_\e[38;5;208m\H\e[0m]\$ '
