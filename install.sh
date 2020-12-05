#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$(pwd)"

project_name="$1"
shift
additionnal_environments=$@

initialize_script_name="initialize_chef_repo"
git_org="jimbodragon"
git_branch="master"
data_dir_name="data"
functions_dir_name="functions"
data_dir="$data_dir_name"
functions_dir="$functions_dir_name"
initialize_install_dir="$current_dir"

function create_directory()
{
  if [ ! -d "$1" ]
  then
    mkdir -p "$1"
  fi
}

function download_github_raw()
{
  file_to_download=$1
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/master/"
  wget --no-cache --no-cookies --quiet -O "$file_to_download" "$raw_url/$file_to_download" > /dev/null
}

create_directory "$data_dir"
create_directory "$functions_dir"
download_github_raw "$data_dir_name/initialize.sh"
download_github_raw "$functions_dir_name/initialize.sh"

source $functions_dir/initialize.sh
download_project

source $install_dir/source_project.sh
create_build_file $project_name
. $build_file
