#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"

function create_directory()
{
  folder_path=$1
  if [ ! -d $folder_path ]
  then
    mkdir -p $folder_path
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

function download()
{
  wget --quiet --no-cache --no-cookies -O $1 $2
}
export -f download

function download_github_raw()
{
  file_to_download=$1
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/master"
  if [ ! -f "$file_to_download" ]
  then
    download "$initialize_install_dir/$file_to_download" "$raw_url/$file_to_download"
  fi
}
export -f download_github_raw

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download_github_raw "$file"
  done
}
export -f download_project

function prepare_project()
{
  download_project
  source $data_dir/project.sh
  source $data_dir/system.sh
  source $functions_dir/generals.sh

  if [ "$chef_repo_path" == "/" ]
  then
    default_install_dir="/usr/local/chef/repo"
    new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$default_install_dir" "$initial_role" "$initial_workstation_cookbook"
    source "/$default_install_dir/$project_name/$functions_dir_name/initialize.sh"
  fi
}
export -f prepare_project

function copy_project()
{
  for file in ${file_list[@]}
  do
    create_directory "$(dirname $1/$file)"
    cp $initialize_install_dir/$file $1/$file
  done
}
export -f copy_project

prepare_project
