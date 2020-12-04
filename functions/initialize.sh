#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"

function create_directory()
{
  folder_path=$1
  if [ ! -d $folder_path ]
  then
    mkdir $folder_path
  fi
}
export -f create_directory

function create_directory_project()
{
  create_directory "$scripts_dir"
  create_directory "$functions_dir"
  create_directory "$initialize_dir"
  create_directory "$build_dir"
  create_directory "$data_dir"
  create_directory "$log_dir"
  create_directory "$install_dir"
}
export -f create_directory_project

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download_github_raw "$file"
  done
}
export -f download_project

function download_github_raw()
{
  file_to_download=$1
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/master/"
  wget --quiet -O "$file_to_download" "$raw_url/$file_to_download"
}
export -f download_github_raw
