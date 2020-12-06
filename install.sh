#!/bin/bash
# Script to execute to initialize a fresh new chef repository

initialize_install_dir="$(pwd)"

project_name="$1"
shift
additionnal_environments=$@

initialize_script_name="initialize_chef_repo"
git_org="jimbodragon"
git_branch="master"
data_dir_name="data"

data_dir="$initialize_install_dir/$data_dir_name"

function create_directory()
{
  folder_path=$1
  echo "Create directory '$folder_path'"
  if [ ! -d $folder_path ]
  then
    mkdir -p $folder_path
  fi
}
export -f create_directory

function download()
{
  echo "Downloading: '$2' => '$1'"
  wget --quiet --no-cache --no-cookies -O $1 $2
}
export -f download

function download_github_raw()
{
  file_to_download=$1
  local_path="$initialize_install_dir/$file_to_download"
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/$git_branch/$file_to_download"
  echo "Downloading from github: '$raw_url' => '$local_path'"
  create_directory $(dirname $local_path)
  download "$local_path" "$raw_url"
}
export -f download_github_raw

export update_require=1
download_github_raw "$data_dir_name/initialize.sh"
source "$initialize_install_dir/$data_dir_name/initialize.sh"
