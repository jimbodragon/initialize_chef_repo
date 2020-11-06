#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $current_dir/../data/$(basename "${BASH_SOURCE[0]}")
source $current_dir/chef.sh

echo "current_dir = $current_dir"
echo
echo "project_name = $project_name"
echo "functions_dir_name = $functions_dir_name"
echo "initialize_dir_name = $initialize_dir_name"
echo "build_dir_name = $build_dir_name"
echo "data_dir_name = $data_dir_name"
echo "log_dir_name = $log_dir_name"
echo

echo "extension = $extension"
echo "source_file = $source_file"
echo "file_name = $file_name"
echo "scripts_dir = $scripts_dir"
echo "functions_dir = $functions_dir"
echo "initialize_dir = $initialize_dir"
echo "data_dir = $data_dir"
echo "log_dir = $log_dir"
echo

function create_directory()
{
  echo "Creating folder $1"
  if [ ! -d "$1" ]
  then
    mkdir "$1"
  fi
}
export -f create_directory

function relative_path()
{
  rel_path="$(echo "$1"| awk -F "$scripts_dir" '{print $2}')"
  echo "relative_path = $rel_path"
  return $rel_path
}
export -f relative_path

function download()
{
  raw_url="$http_git/$project_name/$git_branch"
  echo "Remove $scripts_dir from path $1 to download on $raw_url"
  script_relative_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  echo "Download file $downloadurl to $1"
  wget -O "$1" "$downloadurl"
  chmod a+x "$1"
  echo -e "\n"
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

  echo "Downloading file list: ${file_list[@]}"
  for file in ${file_list[@]}
  do
    echo "Downloading $file"
    download "$file"
    read -p "Download complete of $file"
    echo -e "\n\n"
  done
}
export -f download_project

function prepare_project()
{
  create_directory_project
  download_project
}
export -f prepare_project
