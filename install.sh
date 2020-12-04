#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$(pwd)"

http_git="https://raw.githubusercontent.com/JimboDragonGit"
git_branch="master"

project_name="$1"
shift
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
  download "$data_dir/generals.sh"
  source $data_dir/generals.sh
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

if [ ! -f $build_file ]
then
  cat << EOF  >$build_file
current_dir="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "\$(dirname \$current_dir)/functions/initialize.sh"
install_chef_workstation
#new_chef_infra "\$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path"
new_chef_infra "$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path"
cd \$cookbook_path
git clone git@github.com:jimbodragon/chef_workstation_initialize.git > /dev/null 2>&1
execute_chef_solo $current_dir "$project_name"
EOF
fi

. $build_file
