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
}
export -f source_all_require_files

function download_latest_files() {
  download_project
  source_all_require_files
}
export -f download_latest_files

function repeat_command()
{
  while [ 1 -eq 1 ]
  do
    for day in {0..365}
    do
      for hour in {0..24}
      do
        for min in {0..59}
        do
          echo "******************************   $day day $hour h $min min $sec sec: Starting '$5'   ******************************"

          for sec in `seq 0 $1 59`
          do
            echo "$hour h $min min $sec sec"
            if [ $day -eq $4 ] && [ $hour -eq $3 ] && [ $min -eq $2 ] || [ "$day$hour$min" == "000" ]
            then
              eval $(echo -e "$5")
            else
              sleep $1
            fi
          done
          echo "******************************   $day day $hour h $min min $sec sec: Stopping '$5'   ******************************"
        done
      done
    done
  done
}
export -f repeat_command

function wait_for_project_command()
{
  repeat_command $jump_in_second $max_min $max_hour $max_day "$1"
}
export -f wait_for_project_command

function clear_project()
{
  cd $initial_current_dir
  rm -rf $default_chef_path
  rm install.sh*
  rm -rf $functions_dir_narm
  rm -rf $initialize_dir_name
  rm -rf $build_dir_name
  rm -rf $data_dir_name
  rm -rf $log_dir_name
  rm -rf $install_dir_name
  is_good=$(validate_project)

  case $is_good in
    "1" )
      rm -rf $chef_repo_path
      ;;
  esac
}
export -f clear_project

function download_and_run_project()
{
  cd $initial_current_dir
  if [ ! -f "$install_file_name" ]
  then
    rm -f "$install_file_name"
  fi
  download_github_raw "$install_file_name"
  bash "$install_file_name" $project_name
}
export -f download_and_run_project

function valide_chef_repo()
{
  is_good="1"
  if [ "$chef_repo_path" == "/" ]
  then
    is_good="0"
  fi
  echo "$is_good"
}
export -f valide_chef_repo

function validate_project()
{
  is_good="1"
  chef_repo_good=$(valide_chef_repo)
  if [ $chef_repo_good -eq 1 ]
  then
    is_good="0"
  fi
  echo "$is_good"
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
  echo "Running project $project_name at $chef_repo_path"
  is_good=$(validate_project)
  echo "is_good = $is_good"

  case $is_good in
    "0" )
      echo "Houston we got a problem: installing on default path: $default_chef_path"

      initialize_install_dir="$chef_repo_path/$(basename $scripts_dir)/$initialize_script_name"
      rename_project $project_name
      run_project
      ;;
    "1" )
      echo "chef_repo_running = $chef_repo_running"
      if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
      then
          echo "Running project $project_name"
          export chef_repo_running=1
          create_build_file $build_file
          wait_for_project_command ". $build_file"
          # wait_for_project_command "clear_project\ndownload_and_run_project"
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
