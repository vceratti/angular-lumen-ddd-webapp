#!/usr/bin/env bash

# include sh with functions to ask, check and install apt packages
root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

project_name=""

function usage {
    printf "
Usage: new-project.sh <options>

Possible parameters:
--project-name=<project name used for docker compose images>

"
    exit 1
}

args="project-name:"

OPTIONS=$(getopt -o a: --long ${args} -- "$@" 2> /dev/null)

if [[ $? -ne 0 ]]
then
    usage
fi

eval set -- "$OPTIONS"

while true ; do
    case "$1" in
        --project-name ) project_name="${2}"; shift 2;;
        --  ) shift; break;;
        * ) echo $1; usage;;
    esac
done

branch="master"
php="php"
api_path="$root/api"
git_token="5e2cd84c632e063ff21675e6c65387a9556236c1"

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
dddsample-1.1.0
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
    printf ' --- Cleaning old files and api folder (may ask root permission) ... '

    sudo rm -rf "$api_path" &> /dev/null

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

function make_git_hook {
    if should_run_command "Install pre-commit git-hook?   This will link the defaul pre-commit to ./git-hooks/pre-commit, so you can run it and share them with your team. "; then
        find ./git-hooks -name "*" -exec chmod +x {} \;

        printf " -- Backing up old pre-commit hook\n"
#        rm -rf ../git-hooks 2> /dev/null
        cp -R ./.git/hooks ./.git/hooks.old 2> /dev/null

        rm -f ./.git/hooks/pre-commit 2> /dev/null

        printf " -- Linking <project_root>/.git/hooks/pre-commit to <project_root>/git-hooks/pre-commit\n"
        ln -s -f ../../git-hooks/pre-commit ./.git/hooks/pre-commit

        find ./.git/hooks/ -name "*" -exec chmod +x {} \;
    fi
}

function idea_settings {
    if should_run_command "Create .idea folders with ideal PHPStorm config?"; then
        mv ./.idea/ ./.idea-backup
        rm -Rf ./.idea/
        mv ./.idea-files/ ./.idea/

        mv ./.idea/project-name.iml "./.idea/${project_name}.iml"
        sed -r --in-place "s/project\name/${project_name}/g;" ./.idea/modules.xml
    fi
}

function fix_permissions {
    cd api && docker-compose up -d
    cd "${root}" && docker exec -it "${project_name}_build" chown -R `stat -c "%u:%g" .` .
}

function remove_git_folder {
    if should_run_command "Delete .git folder?"; then
        rm -R ./.git
    fi
}


function main {
    printf "\n  ---- New Project Generator  ----- \n\n"

    clean
    make_api_folder
    choose_project_name
    check_install "git"
    choose_env
#
    start_lumen_api
    make_git_hook
    idea_settings

    remove_git_folder
}

main
