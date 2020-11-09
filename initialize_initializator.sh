#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$(pwd)"

http_git="https://raw.githubusercontent.com/JimboDragonGit"
git_branch="master"

project_name="$1"
functions_dir_name="functions"
initialize_dir_name="initialize"
build_dir_name="build"
data_dir_name="data"
log_dir_name="logs"
install_dir_name="install"
extension=".sh"

source_file="${BASH_SOURCE[0]}"
file_name="$(basename $source_file)"

scripts_dir="$current_dir/$project_name"
initialize_dir="$scripts_dir/$initialize_dir_name"
functions_dir="$scripts_dir/$functions_dir_name"
build_dir="$scripts_dir/$build_dir_name"
data_dir="$scripts_dir/$data_dir_name"
log_dir="$scripts_dir/$log_dir_name"
install_dir="$scripts_dir/$install_dir_name"

build_file="$build_dir/$project_name$extension"

file_list=(
  "$initialize_dir/initializing_chef_repo.sh"
  "$initialize_dir/git_clone_project.sh"
  "$functions_dir/initialize.sh"
  "$functions_dir/generals.sh"
  "$functions_dir/git.sh"
  "$functions_dir/chef.sh"
  "$data_dir/generals.sh"
  "$data_dir/git.sh"
  "$data_dir/chef.sh"
  "$data_dir/initialize.sh"
  "$data_dir/project.sh"
  "$install_dir/install_chef_infra.sh"
  "$install_dir/start_ubuntu_chef_server.sh"
  "$build_dir/$project_name$extension"
  "$scripts_dir/$file_name"
)

function create_directory()
{
  if [ ! -d "$1" ]
  then
    mkdir "$1"
  fi
}

function download()
{
  raw_url="$http_git/$project_name/$git_branch"
  script_relative_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  wget --quiet -O "$1" "$downloadurl"
  chmod a+x "$1"
}

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

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download "$file"
  done
}

function prepare_project()
{
  create_directory_project
  download_project
}

prepare_project
. $build_file
