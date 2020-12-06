#!/bin/bash

function initialize_parameters()
{
  export source_file="${BASH_SOURCE[0]}"
  export file_name="$(basename $source_file)"
  export data_dir="$(dirname $source_file)"
  export initialize_install_dir="$(dirname $data_dir)"

  export scripts_dir="$(dirname $initialize_install_dir)"
  export chef_repo_path="$(dirname $(dirname $initialize_install_dir))"
  export chef_path="$(dirname "$chef_repo_path")"
}
export -f initialize_parameters

function redefine_initialize_data()
{
  export functions_dir_name="functions"
  export initialize_dir_name="initialize"
  export build_dir_name="build"
  export data_dir_name="data"
  export log_dir_name="logs"
  export install_dir_name="install"
  export extension=".sh"

  export initialize_dir="$initialize_install_dir/$initialize_dir_name"
  export functions_dir="$initialize_install_dir/$functions_dir_name"
  export build_dir="$initialize_install_dir/$build_dir_name"
  export data_dir="$initialize_install_dir/$data_dir_name"
  export log_dir="$initialize_install_dir/$log_dir_name"
  export install_dir="$initialize_install_dir/$install_dir_name"

  export build_file="$build_dir/$project_name$extension"

  export file_list=(
    "$initialize_dir_name/initializing_chef_repo.sh"
    "$initialize_dir_name/git_clone_project.sh"
    "$functions_dir_name/initialize.sh"
    "$functions_dir_name/generals.sh"
    "$functions_dir_name/git.sh"
    "$functions_dir_name/chef.sh"
    "$data_dir_name/generals.sh"
    "$data_dir_name/git.sh"
    "$data_dir_name/chef.sh"
    "$data_dir_name/initialize.sh"
    "$data_dir_name/system.sh"
    "$data_dir_name/project.sh"
    "$install_dir_name/source_project.sh"
    "$install_dir_name/git_clone.sh"
    "$build_dir_name/$project_name$extension"
  )

  if [ "$chef_repo_running" != "" ]
  then
    export chef_repo_running=0
  fi
}
export -f redefine_initialize_data

redefine_initialize_data
