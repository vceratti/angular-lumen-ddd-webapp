#!/usr/bin/env bash

function error {
    print_l $1
    exit 1
}

function print_l {
    text=$@
    echo "$@"
    echo ''
}

function empty_str_cmd {
    cmd_return="$1"

    if [ "$cmd_return" = "" ]; then
        return 0;
    fi;
    return 1
}

function is_installed {
    app_name=$1

    isInstalled=`dpkg-query -s "$app_name" 2> /dev/null | grep -isE 'status: install ok'`

    if empty_str_cmd "$isInstalled"; then
        return 1
    fi
    return 0
}

function apt_install {
    app=$1
    echo ""
    print_l "Installing $app (may ask root permission)..."
    sudo apt-get -y install "$app" &> /dev/null
}

function check_install {
    app=$1

    echo "Checking $app installation ..."

    if ! is_installed "$app"; then
        apt_install "$app"
    fi
    if ! is_installed "$app"; then
        error "Could not install $app; please install it and re-run this script"

    fi
    print_l "$app installed!"
}
function should_run_command {
    read -p "$1 (y/n)? " choice

    case "$choice" in
      y|Y ) return 0;;
      n|N ) return 1;;
      * ) return 1;;
    esac
}

function ask_and_install {
    cmd=$1

    if should_run_command "Check and install $cmd"; then
        check_install "$cmd"
    fi
}
