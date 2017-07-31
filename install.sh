#!/usr/bin/env bash

# include sh with functions to ask, check and install apt packages
root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

branch="master"
php="php"
api_path="$root/api"
git_token="5e2cd84c632e063ff21675e6c65387a9556236c1"

project_name=""

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

    printf " --- Checking $app installation ..."

    if ! is_installed "$app"; then
        apt_install "$app"
    fi
    if ! is_installed "$app"; then
        error "Could not install $app; please install it and re-run this script"

    fi
    printf "$app installed!\n"
}
function should_run_command {
    read -p " --- $1 (y/n)? " choice

    case "$choice" in
      y|Y ) return 0;;
      n|N ) return 1;;
      * ) return 1;;
    esac
}

function ask_and_install {
    cmd=$1

    if should_run_command " --- Check and install $cmd"; then
        check_install "$cmd"
    fi
}

function checkout_build_repo {
    echo " --- Checking out and installing into $api_path..."

    rm -rf build
    mkdir build
    cd build
    git init  &> /dev/null
    git pull "https://$git_token@github.com/vceratti/php-build-tools.git" "$branch" &> /dev/null

    cd "$root"
}
function install_php_build {
    if should_run_command "Install php-build-tools?    This will checkout build files and install some tools (like Ant and Docker)"; then
        checkout_build_repo

        cd "build"
        chmod +x install.sh
        ./install.sh "$project_name"
        cd "$root"
        mv build "$api_path/build"
        mv  docker-compose.yml "$api_path/docker-compose.yml"
        mv  docker-php-build-up.sh "$api_path/docker-php-build-up.sh"
        mv  php-build "$api_path/php-build"

    fi
}

function start_lumen_api {
    if should_run_command "Run composer and start a Lumen project?"; then
        checkout_build_repo
        cd build
        chmod +x install.sh
        exec ./install.sh
        php="docker exec -it php-build7.1 php -i"
        cd "$root"
    fi

}


function choose_env {
    printf ' --- Choose an environment setting: \n'
    printf ' 1) PHP 7.1 and MariaDB (latest)\n'
    printf ' 2) PHP 5.6 and MySQL 5.6   '

    read -r env

    if (( env == 1 )); then
        branch="php71-api"
    fi

    if (( env == 2 )); then
        branch="php56-api"
    fi

    printf "\n"
}

function clean {
    printf ' --- Cleaning old files and api folder ((may ask root permission) ... '
    sudo rm -rf git-hooks build .mysql &> /dev/null
    sudo rm docker-up.sh docker-compose.yml php.sh &> /dev/null
    sudo rm -rf "$api_path" &> /dev/null
    sudo rm -rf build git-hooks &> /dev/null

    printf "Done!\n"
}

function make_api_folder {
    mkdir "$api_path"
}

function choose_project_name {
    while empty_str_cmd "$project_name"; do

        printf ' --- Choose a project name: '

        read -r project_name
    done

    printf "\n\tYour project name is: $project_name \n\n"
}

function main {
    printf "\n  ---- New Project Generator  ----- \n\n"
    clean
    make_api_folder
    choose_project_name
    check_install "git"
    choose_env

    install_php_build
#    start_lumen_api
#    idea_settings

}

main
