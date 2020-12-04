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
data_dir="$current_dir/$data_dir_name"
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
  initialize_script_name=$1
  file_to_download=$2
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/master/"
  wget --quiet -O "$file_to_download" "$raw_url/$file_to_download"
}

create_directory "$data_dir"
download_github_raw "$data_dir/generals.sh"
download_github_raw "$data_dir/initialize.sh"
source $data_dir/initialize.sh
source $data_dir/generals.sh

prepare_project
create_build_file $project_name

. $build_file
