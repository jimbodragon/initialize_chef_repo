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

function log()
{
  echo "$1" > /dev/stderr
}
export -f log

function log_subtitle()
{
  log "******************************   $1   ******************************"
}
export -f log_subtitle

function log_title()
{
  log
  log "----------------------------------------------------------------------------------------------"
  log "$1"
  log "----------------------------------------------------------------------------------------------"
  log
}
export -f log_title

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
  log "Downloading latest files $chef_repo_path | $project_name"
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
          log_subtitle "$day day $hour h $min min $sec sec: Starting '$5'"

          for sec in `seq 0 $1 59`
          do
            log "$hour h $min min $sec sec"
            if [ $day -eq $4 ] && [ $hour -eq $3 ] && [ $min -eq $2 ] || [ "$day$hour$min$sec" == "000$1" ]
            then
              eval $(log-e "$5")
            else
              sleep $1
            fi
          done
          log_subtitle "$day day $hour h $min min $sec sec: Stopping '$5'"
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
  log "Clear Project: $chef_repo_path | $project_name"
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
      log "Clear all chef_repo_path: $chef_repo_path | $project_name"
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
  log "valide chef repo at '$chef_repo_path'" > /dev/stderr
  chef_repo_path_is_ok="1"
  if [ "$chef_repo_path" == "/" ]
  then
    chef_repo_path_is_ok="0"
    log "chef_repo_path cannot be '/'" > /dev/stderr
    read -p "Press 'ENTER' to continue: "
  elif [ "$(basename $chef_repo_path)" != "$project_name" ]
  then
    log "chef_repo_path must contain the project_name: '$chef_repo_path'" > /dev/stderr
    read -p "Press 'ENTER' to continue: "
    chef_repo_path_is_ok="0"
  fi
  log "$chef_repo_path_is_ok"
}
export -f valide_chef_repo

function validate_project()
{
  project_is_good="1"
  chef_repo_good="$(valide_chef_repo)"
  log "chef_repo_good? = $chef_repo_good" > /dev/stderr
  if [ "$chef_repo_good" == "0" ]
  then
    project_is_good="0"
  fi
  log "$project_is_good"
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
  log "Preparing project for source_file '$source_file'"
  if [ "$is_require_git_clone" != "" ] && [ $is_require_git_clone -eq 1 ]
  then
    log "Cloning the project"
    git_clone_main_project
    chef_import_submodule
  else
    log "Check if chef_repo_running before downloading = $chef_repo_running"
    if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
    then
      download_latest_files
    fi
  fi

  redefine_data
}
export -f prepare_project

function run_project()
{
  log "Running project $project_name at $chef_repo_path"
  is_good=$(validate_project)
  log "is_good = $is_good"

  case $is_good in
    "0" )
      log_title "Houston we got a problem: installing on default path: $default_chef_path"
      read -p "Press 'ENTER' to continue: "

      new_source_file="$default_chef_path/$project_name/$(basename $scripts_dir)/$initialize_script_name/$data_dir_name/$(basename ${BASH_SOURCE[0]})"
      log "Switching to new_source_file '$new_source_file': Old one is '$source_file'"
      initialize_parameters "$new_source_file"
      redefine_data
      rename_project $project_name
      read -p "Press 'ENTER' to continue: "
      run_project
      ;;
    "1" )
      log "Check if chef_repo_running before running = $chef_repo_running"
      if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
      then
          log "Running project $project_name"
          read -p "Press 'ENTER' to continue: "
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
