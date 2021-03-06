rp_module_id="retronetplay"
rp_module_desc="RetroNetplay"
rp_module_menus="4+"
rp_module_flags="nobin"

function rps_retronet_saveconfig() {
    cat > "$configdir/all/retronetplay.cfg" <<_EOF_
__netplaymode="$__netplaymode"
__netplayport="$__netplayport"
__netplayhostip="$__netplayhostip"
__netplayhostip_cfile="$__netplayhostip_cfile"
__netplayframes="$__netplayframes"
_EOF_
    chown $user:$user "$configdir/all/retronetplay.cfg"
}

function rps_retronet_loadconfig() {
    if [[ -f "$configdir/all/retronetplay.cfg" ]]; then
        source "$configdir/all/retronetplay.cfg"
    else
        __netplayenable="D"
        __netplaymode="H"
        __netplayport="55435"
        __netplayhostip="192.168.0.1"
        __netplayhostip_cfile=""
        __netplayframes="15"
    fi
}

function rps_retronet_mode() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Please set the netplay mode." 22 76 16)
    options=(1 "Set as HOST"
             2 "Set as CLIENT" )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
             1) __netplaymode="H"
                __netplayhostip_cfile=""
                ;;
             2) __netplaymode="C"
                __netplayhostip_cfile="$__netplayhostip"
                ;;
        esac
        rps_retronet_saveconfig
    fi
}

function rps_retronet_port() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the port to be used for netplay (default: 55435)." 22 76 $__netplayport)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplayport="$choice"
        rps_retronet_saveconfig
    fi
}

function rps_retronet_hostip() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the IP address of the host." 22 76 $__netplayhostip)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplayhostip="$choice"
        if [[ $__netplaymode == "H" ]]; then
            __netplayhostip_cfile=""
        else
            __netplayhostip_cfile="$__netplayhostip"
        fi
        rps_retronet_saveconfig
    fi
}

function rps_retronet_frames() {
    cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the number of delay frames for netplay (default: 15)." 22 76 $__netplayframes)
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        __netplayframes="$choice"
        rps_retronet_saveconfig
    fi
}

function configure_retronetplay() {
    rps_retronet_loadconfig

    local ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    local ip_ext=$(wget -O- -q http://ipecho.net/plain)

    while true; do
        cmd=(dialog --backtitle "$__backtitle" --menu "Configure RetroArch Netplay.\nInternal IP: $ip_int External IP: $ip_ext" 22 76 16)
        options=(1 "Set mode, (H)ost or (C)lient. Currently: $__netplaymode"
                 2 "Set port. Currently: $__netplayport"
                 3 "Set host IP address (for client mode). Currently: $__netplayhostip"
                 4 "Set delay frames. Currently: $__netplayframes")
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            case $choice in
                 1) rps_retronet_mode ;;
                 2) rps_retronet_port ;;
                 3) rps_retronet_hostip ;;
                 4) rps_retronet_frames ;;
            esac
        else
            break
        fi
    done
}
