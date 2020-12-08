#!/bin/bash
function initialize_parameters()
{
  export source_file="$1"
  export file_name="$(basename $source_file)"
  export data_dir="$(dirname $source_file)"
  export initialize_install_dir="$(dirname $data_dir)"

  export scripts_dir="$(dirname $initialize_install_dir)"
  export chef_repo_path="$(dirname $(dirname $initialize_install_dir))"
  export chef_path="$(dirname "$chef_repo_path")"

  redefine_message="Redefine initialize parameters from file '$1': $chef_repo_path | $project_name"
  if [ "$(type debug_log 2>&1 | grep "is a function")" == "debug_log is a function" ]
  then
    debug_log "$redefine_message"
  else
    echo "$redefine_message"
  fi
}
export -f initialize_parameters

function redefine_initialize_data()
{
  redefine_message="Redefine initialize data: $chef_repo_path | $project_name"
  if [ "$(type debug_log 2>&1 | grep "is a function")" == "debug_log is a function" ]
  then
    debug_log "$redefine_message"
  else
    echo "$redefine_message"
  fi
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

  #   "$build_dir_name/$project_name$extension"
  export file_list=(
    "$functions_dir_name/$(basename ${BASH_SOURCE[0]})"
    "$data_dir_name/$(basename ${BASH_SOURCE[0]})"
    "$data_dir_name/project.sh"
    "$data_dir_name/system.sh"
    "$data_dir_name/generals.sh"
    "$data_dir_name/git.sh"
    "$data_dir_name/chef.sh"
    "$functions_dir_name/generals.sh"
    "$functions_dir_name/git.sh"
    "$functions_dir_name/chef.sh"
  )

  if [ "$chef_repo_running" != "" ]
  then
    export chef_repo_running=0
  fi
}
export -f redefine_initialize_data

function run_new_project()
{
  echo
  echo "--------------------------------------------------------------"
  echo "Running new project $project_name at $chef_repo_path"
  echo "--------------------------------------------------------------"
  echo
  download_github_raw "$functions_dir_name/$(basename ${BASH_SOURCE[0]})"
  source "$initialize_install_dir/$functions_dir_name/$(basename ${BASH_SOURCE[0]})"
  run_project
}
export -f run_new_project

initialize_parameters "${BASH_SOURCE[0]}"
redefine_initialize_data

if [ "$(type source_all_require_files 2>&1 | grep "is a function")" == "source_all_require_files is a function" ]
then
  source_all_require_files
fi
