listfonts(){
    fc-list --format="%{family}\n" | sort -u
}
