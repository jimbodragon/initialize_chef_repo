#!/bin/bash
# Script to execute to initialize a fresh new chef repository

initialize_install_dir="$(pwd)"

if [ "$1" == "" ]
then
  echo "Cannot continue without a project name"
  exit
fi

export project_name="$1"
shift
export additionnal_environments=$@

export initialize_script_name="initialize_chef_repo"
export git_org="jimbodragon"
export git_branch="master"
export data_dir_name="data"
export http_git="https://raw.githubusercontent.com"

export initialize_git_org="$git_org"

export data_dir="$initialize_install_dir/$data_dir_name"

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
  if [ ! -f $1 ]
  then
    echo "Downloading: '$2' => '$1'"
    wget --quiet --no-cache --no-cookies -O $1 $2
  fi
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

download_github_raw "$data_dir_name/initialize.sh"
DEBUG_LOG=0
source "$initialize_install_dir/$data_dir_name/initialize.sh"
run_new_project
