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
extension=".sh"

source_file="${BASH_SOURCE[0]}"
# file_name="$(basename $source_file)"
file_name="initialize_initializator.sh"

scripts_dir="$current_dir/$project_name"
initialize_dir="$scripts_dir/$initialize_dir_name"
functions_dir="$scripts_dir/$functions_dir_name"
build_dir="$scripts_dir/$build_dir_name"
data_dir="$scripts_dir/$data_dir_name"
log_dir="$scripts_dir/$log_dir_name"

file_list=("$initialize_dir/initializing_chef_repo.sh" "$initialize_dir/install_chef_infra.sh" "$initialize_dir/git_clone_project.sh" "$functions_dir/generals.sh" "$functions_dir/git.sh" "$functions_dir/chef.sh" "$data_dir_name/generals.sh" "$data_dir_name/git.sh" "$data_dir_name/chef.sh" "$build_dir/$project_name$extension" "$file_name")

echo "current_dir = $current_dir"
echo "project_name = $project_name"
echo "functions_dir_name = $functions_dir_name"
echo "initialize_dir_name = $initialize_dir_name"
echo "build_dir_name = $build_dir_name"
echo "data_dir_name = $data_dir_name"
echo "log_dir_name = $log_dir_name"
echo "extension = $extension"
echo "source_file = $source_file"
echo "file_name = $file_name"
echo "scripts_dir = $scripts_dir"
echo "functions_dir = $functions_dir"
echo "initialize_dir = $initialize_dir"

function create_directory()
{
  echo "Creating folder $1"
  if [ ! -d "$1" ]
  then
    mkdir "$1"
  fi
}

function relative_path()
{
  rel_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  echo "relative_path = $rel_path"
  return $rel_path
}

function download()
{
  raw_url="$http_git/$project_name/$git_branch"
  echo "Remove $scripts_dir from path $1"
  script_relative_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  echo "Download file $downloadurl to $1"
  wget -O "$1" "$downloadurl"
  chmod a+x "$1"
  echo -e "\n\n\n\n"
}

echo "Functions Loaded"

create_directory "$scripts_dir"
create_directory "$functions_dir"
create_directory "$initialize_dir"
create_directory "$build_dir"
create_directory "$data_dir"
create_directory "$log_dir"

echo "Downloading file list: ${file_list[@]}"
for file in ${file_list[@]}
do
  echo "Downloadoing $file"
  download "$scripts_dir/$file"
done

for environment in "$project_name" "$@"
do
    source ${BASH_SOURCE[0]}
    if [ "$environment" ==  "$project_name" ]
    then
      initial_script_file="$build_dir/$project_name$extension"
    else
      initial_script_file="$build_dir/$project_name-$environment$extension"
    fi
    echo "Execute file $initial_script_file"
    download_raw $initial_script_file
    sleep 5

    bash "$initial_script_file"
    echo -e "\n\n\n\n"
done
