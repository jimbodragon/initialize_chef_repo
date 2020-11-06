#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $current_dir/../data/$(basename "${BASH_SOURCE[0]}")
source $current_dir/chef.sh

function create_directory()
{
  if [ ! -d "$1" ]
  then
    mkdir "$1"
  fi
}
export -f create_directory

function relative_path()
{
  rel_path="$(echo "$1"| awk -F "$scripts_dir" '{print $2}')"
  return $rel_path
}
export -f relative_path

function download()
{
  raw_url="$http_git/$project_name/$git_branch"
  script_relative_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  wget --quiet -O "$1" "$downloadurl"
  chmod a+x "$1"
}
export -f download

function create_directory_project()
{
  create_directory "$scripts_dir"
  create_directory "$functions_dir"
  create_directory "$initialize_dir"
  create_directory "$build_dir"
  create_directory "$data_dir"
  create_directory "$log_dir"
}
export -f create_directory_project

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download "$file"
  done
}
export -f download_project

function prepare_project()
{
  create_directory_project
  download_project
}
export -f prepare_project
