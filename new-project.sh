#!/usr/bin/env bash

# include sh with functions to ask, check and install apt packages
root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

project_name=""
branch=""
api_path="$root/api"

libVersion="1.0.5"

function importLib {
    removeLib
    printf  "\n downloading files...\n"
    mkdir "bash-scripts-${libVersion}"
    wget "https://github.com/vceratti/bash-scripts/archive/$libVersion.tar.gz" &> /dev/null
    tar -xf "$libVersion.tar.gz"
    rm "$libVersion.tar.gz"

}

function removeLib {
    find . -type d -name "bash-scripts-*" -exec rm -rf {} \; &> /dev/null
}

importLib

source "$root/bash-scripts-$libVersion/lib.sh"

function start_lumen_api {
    if should_run_command "Checkout API project ?"; then
        checkout_api
        cd "$api_path"
        chmod +x ./new-api-project.sh
        ./new-api-project.sh --project-name="$project_name" --branch="$branch"

        cd "$root"
    fi

}

function checkout_api {
    log_wait "Checking out lumen-ddd-api and installing build-tools"

    make_api_folder

    old_root="$root"
    root="$api_path"

    cd "$api_path"
    git clone "https://github.com/vceratti/lumen-ddd-api.git" . &> /dev/null
    rm -Rf "${api_path}/.git"

    log_done
    root="$old_root"
    cd "$root"
}


function choose_env {
    if  empty_str_cmd "$branch"; then
        log "Choose an environment setting: \n     1) PHP 7.1 and MariaDB (latest)\n     2) PHP 5.6 and MySQL 5.6   "

        read -r env
        newline
    fi

    if (( env == 1 )); then
        branch="php71-api"
    fi

    if (( env == 2 )); then
        branch="php56-api"
    fi
}

function clean {
    log_wait 'Cleaning old files and api folder (may ask root permission)'

    sudo rm -rf "$api_path" &> /dev/null
    sudo rm -rf ".git-hooks" &> /dev/null

    log_done
}

function make_api_folder {
    mkdir "$api_path"
}


function make_git_hook {
    if should_run_command "Install pre-commit git-hook?   This will link the default pre-commit to ./git-hooks/pre-commit, so you can run it and share them with your team. "; then
        find ./git-hooks -name "*" -exec chmod +x {} \;

        log_wait "Backing up old pre-commit hook"
#        rm -rf ../git-hooks 2> /dev/null
        cp -R ./.git/hooks ./.git/hooks.old 2> /dev/null

        rm -f ./.git/hooks/pre-commit 2> /dev/null
        log_done

        log_wait "Linking <project_root>/.git/hooks/pre-commit to <project_root>/git-hooks/pre-commit"
        ln -s -f ../../git-hooks/pre-commit ./.git/hooks/pre-commit

        find ./.git/hooks/ -name "*" -exec chmod +x {} \;
        log_done
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
    log_wait "Fixing folder permissions and setting current user as owner"

    docker rm -f $(docker ps) &> /dev/null

    cd "$api_path" && docker-compose up -d &> /dev/null
    cd "${root}" && docker exec -it "${project_name}_php_build" chown -R `stat -c "%u:%g" .` .

    cd "$api_path" && docker-compose down -d &> /dev/null

    cd "$root"

    log_done
}

function remove_git_folder {
    if should_run_command "Delete .git folder?"; then
        cd "$root"
        rm -Rf ./.git
    fi
}


function main {
    log_title "New Project Generator"

    clean
    choose_project_name
    check_install "git"
    choose_env

    start_lumen_api
    # make_git_hook
    idea_settings
    remove_git_folder
    fix_permissions
    removeLib

    log_title "Project ${project_name} successfully created!"
    exit 0
}

main
