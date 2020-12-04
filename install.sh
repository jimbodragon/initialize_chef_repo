#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$(pwd)"

project_name="$1"
shift
additionnal_environments=$@

http_git="https://raw.githubusercontent.com/JimboDragonGit"
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

function download_git_raw()
{
  raw_url="$http_git/$project_name/$git_branch"
  script_relative_path="$(echo $1 | awk -F "$initialize_install_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  wget --quiet -O "$1" "$downloadurl"
  chmod a+x "$1"
}

create_directory "$data_dir"
download_git_raw "$data_dir/generals.sh"
download_git_raw "$data_dir/initialize.sh"
source $data_dir/initialize.sh
source $data_dir/generals.sh

prepare_project
create_build_file $project_name

. $build_file
