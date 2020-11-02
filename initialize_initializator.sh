#!/bin/bash
# Script to execute to initialize a fresh new chef repository

# https://raw.githubusercontent.com/jimbodragon/initialize_chef_repo/main/initialize_initializator.sh
# wget https://raw.githubusercontent.com/jimbodragon/initialize_chef_repo/main/initialize_initializator.sh && bash initialize_initializator.sh && bash initialize_chef_repo/initialize/start_ubuntu_chef_server.sh


current_dir="$(pwd)"

scripts_dir_name="initialize_chef_repo"
functions_dir_name="functions"
initialize_dir_name="initialize"
initializator_script_name="initialize_initializator.sh"

scripts_dir="$current_dir/$scripts_dir_name"
functions_dir="$scripts_dir/$functions_dir_name"
initialize_dir="$scripts_dir/$initialize_dir_name"

function create_directory()
{
  if [ ! -d $1 ]
  then
    mkdir $1
  fi
}

function download_raw()
{
  raw_url="https://raw.githubusercontent.com/jimbodragon/initialize_chef_repo/main/"
  script_relative_path=$(echo $1 | awk -F "$scripts_dir/" '{print $2}')
  wget --quiet -O "$1" "$raw_url/$script_relative_path"
}

create_directory "$scripts_dir"
create_directory "$functions_dir"
create_directory "$initialize_dir"


download_raw "$scripts_dir/cookbooks.sh"
download_raw "$scripts_dir/initialize_initializator.sh"
download_raw "$functions_dir/generals.sh"
download_raw "$functions_dir/git.sh"
download_raw "$initialize_dir/git_clone_project.sh"
download_raw "$initialize_dir/git_push.sh"
download_raw "$initialize_dir/initializing_chef_repo.sh"
download_raw "$initialize_dir/install_chef_infra.sh"
download_raw "$initialize_dir/start_ubuntu_chef_server.sh"
