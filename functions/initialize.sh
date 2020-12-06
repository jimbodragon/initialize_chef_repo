#!/bin/bash
# Script to execute to initialize a fresh new chef repository

source "$data_dir/$(basename "${BASH_SOURCE[0]}")"

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
  local_path="$initialize_install_dir/$file_to_download"
  raw_url="https://raw.githubusercontent.com/$git_org/$initialize_script_name/$git_branch/$file_to_download"
  create_directory $(dirname $local_path)
  download "$local_path" "$raw_url"
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

function source_all_require_files()
{
  for file in ${file_list[@]}
  do
    source "$initialize_install_dir/$file"
  done
  for fil
}
export -f download_all_require_files

function download_latest_files() {
  download_project
  source_all_require_files
}
export -f download_latest_files

function wait_for_command()
{
  while [ 1 -eq 1 ]
  do
    for hour in {0..9999}
    do
      for min in {0..59}
      do
        echo "******************************   $hour h $min min $sec sec: Starting '$4'   ******************************"
        eval echo -en "$4"
        for sec in `seq 0 $1 59`
        do
          echo "$hour h $min min $sec sec"
          let "adjust_hour=$3 - 1"
          let "adjust_min=$2 - 1"
          if [ $hour -eq $adjust_hour ] && [ $min -eq $adjust_min ]
          then
            sleep $1
          fi
        done
        echo "******************************   $hour h $min min $sec sec: Stopping '$4'   ******************************"
      done
    done

  done
}
export -f wait_for_command

function wait_for_project_command()
{
  # wait_for_command $jump_in_second $max_min $max_hour $build_file

  wait_for_command "\ncd $initial_current_dir\nrm -rf /usr/local/chef/\nrm install.sh\nrm -rf data/\nrm -rf functions/\nrm -rf build/\nrm -rf initialize/\nrm -rf install/\nrm -rf logs/\nwget --quiet --no-cache --no-cookies https://raw.githubusercontent.com/jimbodragon/initialize_chef_repo/master/install.sh && bash install.sh $project_name"
}
export -f wait_for_project_command

function valide_chef_repo()
{
  eval "$1=1"
  if [ "$chef_repo_path" == "/" ]
  then
    eval "$1=0"
  fi
}
export -f valide_chef_repo

function validate_project()
{
  valide_chef_repo chef_repo_good
  if [ $chef_repo_good -eq 1 ]
  then
    eval "$1=0"
  fi
}
export -f validate_project

function redefine_data()
{
  redefine_initialize_data
  redefine_general_data
  redefine_chef_data
  redefine_git_data

  redefine_system_data
  redefine_project_data
}
export -f redefine_data

function prepare_project()
{
  initialize_parameters $source_file
  redefine_initialize_data
  if [ "$is_require_git_clone" != "" ] && [ $is_require_git_clone -eq 1 ]
  then
    git_clone_main_project
    chef_import_submodule
  fi
  download_latest_files

  redefine_data
}
export -f prepare_project

function run_project()
{
  prepare_project
  validate_project is_good

  new_chef_infra "$project_name" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_repo_path" "$initial_role" "$initial_workstation_cookbook" "$default_chef_path" "$is_require_git_clone"

  case $is_good in
    0 )
      echo "Houston we got a problem: installing on default path: $default_chef_path"
      initialize_install_dir="$chef_repo_path/$(basename $scripts_dir)/$initialize_script_name"
      redefine_data
      source "$data_dir/$(basename "${BASH_SOURCE[0]}")"
      ;;
    1 )
      if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
      then
          export chef_repo_running=1
          create_build_file $build_file
          wait_for_project_command $build_file
      fi
      ;;
  esac
}
export -f run_project

function copy_project()
{
  for file in ${file_list[@]}
  do
    create_directory "$(dirname $1/$file)"
    cp $initialize_install_dir/$file $1/$file
  done
}
export -f copy_project
