#!/usr/bin/env bash

# include sh with functions to ask, check and install apt packages
source "$(dirname "${BASH_SOURCE[0]}")/tools/installer.sh"

php="php"

git_token="5e2cd84c632e063ff21675e6c65387a9556236c1"

function checkout_build_repo {
    echo "Checking out and installing ..."
    rm -rf build
    mkdir build
    cd build
    git init  &> /dev/null
    git pull "https://$git_token@github.com/vceratti/php-build-tools.git" &> /dev/null
    cd ..
}
function install_php_build {
    if should_run_command "Install php-build-tools?"; then
        checkout_build_repo
        cd build
        chmod +x install.sh
        exec ./install.sh
        cd ..
    fi

}

function start_lumen_api {
    if should_run_command "Run composer and start a Lumen project?"; then
        checkout_build_repo
        cd build
        chmod +x install.sh
        exec ./install.sh
        php="docker exec -it php-build7.1 php -i"
        cd ..
    fi

}

function main {
    print_l "  ---- New Project Generator  -----"
    check_install "git"
    install_php_build
#    start_lumen_api
    idea_settings

}

main
