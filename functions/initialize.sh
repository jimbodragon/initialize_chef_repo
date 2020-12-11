#!/bin/bash
# Script to execute to initialize a fresh new chef repository

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
  create_directory "$log_dir"
  echo -e "$1" >> $log_dir/initialize.log
  echo -e "$1" > /dev/stderr
}
export -f log

function debug_log()
{
  if [ "$DEBUG_LOG" != "" ] && [ $DEBUG_LOG -eq 1 ]
  then
    log "$1"
  fi
}
export -f log

function log_bold()
{
  log "******************************   $1   ******************************"
}
export -f log_bold

function log_subtitle()
{
  log "\n----------------------------------------------------------------------------------------------"
  log "$1"
  log "----------------------------------------------------------------------------------------------\n"
}
export -f log_subtitle

function log_title()
{
  log '\n\n--------------------------------------------------------------------------------------------------------\n'
  log "$1"
  log '\n--------------------------------------------------------------------------------------------------------\n\n'

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
  if [ -f $1 ] && [ "$(cat $1 | wc -l)" -gt "0" ]
  then
    echo > /dev/null
  elif [ -f $1 ] && [ "$(cat $1 | wc -l)" -eq "0" ]
  then
    log_bold "File exist but not downloaded correctly: $1"
    log "Retrying download: wget --no-cache --no-cookies -O $1 $2"
    wget --no-cache --no-cookies -O $1 $2
  else
    log_bold "File downloaded does not exist: $1"
    log "Retrying download: wget --no-cache --no-cookies -O $1 $2"
    wget --no-cache --no-cookies -O $1 $2
  fi
}
export -f download

function download_github_raw()
{
  file_to_download=$1
  local_path="$initialize_install_dir/$file_to_download"
  raw_url="$http_git/$initialize_git_org/$initialize_script_name/$git_branch/$file_to_download"
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
  redefine_data
}
export -f source_all_require_files

function download_latest_files() {
  log_bold "Downloading latest files $chef_repo_path | $project_name"
  download_project
  source_all_require_files
}
export -f download_latest_files

function wait_for_command()
{
  for day in {0..365}
  do
    for hour in {0..24}
    do
      for min in {0..59}
      do
        for sec in `seq 0 $1 59`
        do
          log "$day day $hour h $min min $sec sec"
          if [ $day -eq $4 ] && [ $hour -eq $3 ] && [ $min -eq $2 ] && [ $sec -eq 0 ] || [ "$first_run$day$hour$min$sec" == "10000" ]
          then
            eval $(echo -e "$5")
            first_run=0
            return
          else
            sleep $1
          fi
        done
      done
    done
  done
  log_bold "$day day $hour h $min min $sec sec: Stopping '$5'"
  log_bold "$day day $hour h $min min $sec sec: Starting '$5'"
}
export -f wait_for_command

function wait_for_project_command()
{
  log_bold "0 day 0 h 0 min 0 sec: Starting '$5'"
  first_run=1
  while [ 1 -eq 1 ]
  do
    wait_for_command $jump_in_second $max_min $max_hour $max_day "$1"
  done
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
  chef_repo_path_is_ok="1"
  if [ "$chef_repo_path" == "/" ]
  then
    chef_repo_path_is_ok="0"
    log_bold "chef_repo_path cannot be '/'"
  elif [ "$(basename $chef_repo_path)" != "$project_name" ]
  then
    log_bold "chef_repo_path must contain the project_name: '$chef_repo_path'"
    chef_repo_path_is_ok="0"
  fi
  echo "$chef_repo_path_is_ok"
}
export -f valide_chef_repo

function validate_project()
{
  project_is_good="OK"
  if [ ! -f "$chef_repo_path/Berksfile" ]
  then
    log_bold "No Berksfile in : '$chef_repo_path'"
    project_is_good="no_berksfile"
  fi

  if [ ! -f "$solo_file" ]
  then
    log_bold "No '$solo_file' in : '$chef_repo_path'"
    project_is_good="no_solo_file"
  fi

  chef_repo_good="$(valide_chef_repo)"
  if [ "$chef_repo_good" == "0" ]
  then
    project_is_good="bad_chef_repo_path"
  fi

  echo "$project_is_good"
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
  log "Check if chef_repo_running before downloading = $chef_repo_running"
  if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
  then
    log "Preparing project for source_file '$source_file'"
    if [ "$is_require_git_clone" != "" ] && [ $is_require_git_clone -eq 1 ]
    then
      log "Cloning the project"
      git_clone_main_project
      chef_import_submodule
      source_all_require_files
    else
        create_directory_project
        download_latest_files
    fi
  else
    source_all_require_files
  fi
}
export -f prepare_project

function run_project()
{
  prepare_project

  log_title "Running project $project_name at $chef_repo_path"
  state=$(validate_project)

  case $state in
    "no_solo_file" | "no_berksfile" )
      log_title "Error as $state: Preparing the chef repo: $default_chef_path"
      prepare_chef_repo
    ;;
    "OK" )
      log "Check if chef_repo_running before running = $chef_repo_running"
      if [ "$chef_repo_running" == "" ] || [ $chef_repo_running -eq 0 ]
      then
          log_title "Running chef $project_name"
          export chef_repo_running=1
          include_bashrc
          create_build_file $build_file

          wait_for_project_command "execute_chef_solo "$project_name""
          # wait_for_project_command "clear_project\ndownload_and_run_project"
          export chef_repo_running=0
      fi
    ;;
    * )
      log_title "Houston we got a problem (state is $state): installing on default path: $default_chef_path"

      new_project_folder="$default_chef_path/$project_name/$(basename $scripts_dir)/$initialize_script_name"
      new_source_file="$new_project_folder/$data_dir_name/$(basename ${BASH_SOURCE[0]})"
      log_bold "Switching to new_source_file '$new_source_file': Old one is '$source_file'"
      copy_project "$new_project_folder"
      initialize_parameters "$new_source_file"
      redefine_data
      rename_project $project_name
      log_bold "Reexecuting the project"
      prepare_chef_repo
      run_project
      log_title "Project $project_name finished to run"
    ;;
  esac
}
export -f run_project

function copy_project()
{
  for file in ${file_list[@]}
  do
    if [ "$initialize_install_dir/$file" != "$1/$file" ]
    then
      create_directory "$(dirname $1/$file)"
      cp -f $initialize_install_dir/$file $1/$file
    fi
  done
}
export -f copy_project
