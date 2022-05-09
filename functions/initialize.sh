#!/bin/bash
# Script to execute to initialize a fresh new chef repository

function create_directory()
{
  if [ ! -d $1 ]
  then
    if [ "$1" != "$log_dir" ]
    then
      log "Creating folder $1"
    fi
    if [ -f $1 ]
    then
      log "Try to create a folder when it's a file that exit at $1"
    else
      if [ "$2" == "sudo" ]
      then
        cmd="sudo "
      else
        cmd=""
      fi
      $cmd mkdir -p $1
      log "Folder $1 fully created"
    fi
  fi
}
export -f create_directory

function delete_directory()
{
  # folder_path=$1
  if [ -d $1 ]
  then
    log "Deleting folder $1"
    rm -rf $1
  fi
}
export -f delete_directory

function log()
{
  create_directory "$log_dir"
  echo "$@" >> $log_dir/initialize.log
  echo "$@" > /dev/stderr
}
export -f log

function debug_log()
{
  if [ "$DEBUG_LOG" != "" ] && [ $DEBUG_LOG -eq 1 ]
  then
    log "::DEBUG:: $@ ::DEBUG::"
  fi
}
export -f log

function log_bold()
{
  log "******************************   $@   ******************************"
}
export -f log_bold

function log_subtitle()
{
  log -e "\n----------------------------------------------------------------------------------------------"
  log "$@"
  log -e "----------------------------------------------------------------------------------------------\n"
}
export -f log_subtitle

function log_title()
{
  log -e '\n\n--------------------------------------------------------------------------------------------------------\n'
  log "$@"
  log -e '\n--------------------------------------------------------------------------------------------------------\n\n'

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

function delete_directory_project()
{
  delete_directory "$scripts_dir"
  delete_directory "$functions_dir"
  delete_directory "$initialize_dir"
  delete_directory "$build_dir"
  delete_directory "$data_dir"
  delete_directory "$log_dir"
  delete_directory "$install_dir"
}
export -f delete_directory_project

function download()
{
  if [ ! -f $1 ]
  then
    debug_log "Downloading file $2 => $1"
    wget --no-clobber --quiet --no-cache --no-cookies -O $1 $2
  fi
  if [ -f $1 ] && [ "$(cat $1 | wc -l)" -gt "0" ]
  then
    echo > /dev/null
  elif [ -f $1 ] && [ "$(cat $1 | wc -l)" -eq "0" ]
  then
    log_bold "File exist but not downloaded correctly: $1"
    log "Delete destination file and retrying download: wget --no-cache --no-cookies -O $1 $2"
    rm -f $1
    wget --no-clobber --no-cache --no-cookies -O $1 $2
  else
    log_bold "File downloaded but does not exist: $1"
    log "Retrying download: wget --no-cache --no-cookies -O $1 $2"
    rm -f $1
    wget --no-clobber --no-cache --no-cookies -O $1 $2
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
  start_internal_timer=$(date +%s)
  let "expected_restart=$start_internal_timer+(($4*3600)+($3*3600)+($2*60)+$1)"

  while [ $(date +%s) -lt $expected_restart ]
  do
    let "duration=$(date +%s)-$start_internal_timer"
    if [ $duration -gt 0 ]
    then
      log "Next run at '$expected_restart' = $(date -r $expected_restart) for $duration seconds at $start_internal_timer"
      sleep $1
    else
      log_bold "$(date): Starting '$(echo "$5" | tr ';' '\n')'"
      log_title "$(eval "$5")"
      log_bold "$(date): Stopping '$(echo "$5" | tr ';' '\n')'"
    fi
  done
}
export -f wait_for_command

function wait_for_project_command()
{
  debug_log "Executing again $num_exec"
  wait_for_command $jump_in_second $max_min $max_hour $max_day "$1"
}
export -f wait_for_project_command

function clear_project()
{
  log "Clear Project: $chef_repo_path | $project_name"
  for file in ${file_list[@]}
  do
    log "Removing file $initialize_install_dir/$file"
    rm -f "$initialize_install_dir/$file"
  done
  delete_directory_project
  is_good=$(validate_project)

  case $is_good in
    "OK" )
      log "Clear all chef_repo_path: $chef_repo_path | $project_name"
      rm -rf $chef_repo_path
      ;;
    * )
      log "Cannot clear the project at $chef_repo_path"
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
  chef_repo_path_is_ok="OK"
  if [ "$chef_repo_path" == "/" ]
  then
    chef_repo_path_is_ok="root"
    log_bold "chef_repo_path cannot be '/'"
  elif [ "$(basename $chef_repo_path)" != "$project_name" ]
  then
    log_bold "chef_repo_path must contain the project_name: '$chef_repo_path'"
    chef_repo_path_is_ok="no_project_name"
  fi
  echo -n "$chef_repo_path_is_ok"
}
export -f valide_chef_repo

function ord() {
  LC_CTYPE=C printf '%d' "'$1"
}
export -f ord

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

  chef_repo_is_good="$(valide_chef_repo)"
  if [ "$chef_repo_is_good" != "OK" ]
  then
    log_bold "chef_repo_path is not in a desire path '$chef_repo_is_good'"
    project_is_good="$chef_repo_is_good"
  fi

  echo -n "$project_is_good"
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
    source_all_require_files
  else
    create_directory_project
    download_latest_files
  fi
  redefine_data
}
export -f prepare_project

function run_internal_project()
{
  log_title "log_title Running chef $project_name"
  check_and_install procmail

  if [ ! -f $lockfile ]
  then
    touch $lockfile

    cd $initialize_install_dir
    rm -f install.sh*
    download_github_raw install.sh

    log_title "Install $project_name as fresh with environments $additionnal_environments"
    log "Running command: 'bash --norc --noprofile $initialize_install_dir/install.sh $project_name $additionnal_environments'"
    bash --norc --noprofile $initialize_install_dir/install.sh $project_name $additionnal_environments
  else
    log_title "Fetching latest source for project $project_name"
    prepare_project
    prepare_chef_repo
    cd $chef_repo_path
    # wait_for_project_command "knife config show --all"
    wait_for_project_command "execute_chef_solo \"\$project_name\""
    rm -f $lockfile
    log_title "Able to change run_internal_project function dynamically: $project_name"
    run_internal_project
  fi
  log "Here the loaded source files: ${BASH_SOURCE[@]}"
}
export -f run_internal_project

function switch_project() {
  new_project_folder="$1/$project_name/$(basename $scripts_dir)/$initialize_script_name"
  new_source_file="$new_project_folder/$data_dir_name/$(basename ${BASH_SOURCE[0]})"
  switch_for_type=$2
  log_bold "Switching to new_source_file '$new_source_file': Old one is '$source_file'"
  copy_project "$new_project_folder"
  clear_project
  initialize_parameters "$new_source_file"
  redefine_data
  rename_project $project_name
  log_bold "Reexecuting the project"
  prepare_chef_repo
  run_project "$switch_for_type"
  log_title "Project $project_name finished to run"
}
export -f switch_project

function run_project()
{
  run_for_type=$1
  prepare_project

  log_title "Running project $project_name at $chef_repo_path"
  state="$(validate_project)"

  log "State is $state"
  case $state in
    "no_solo_file" | "no_berksfile" )
      log_title "Error as $state: Preparing the chef repo: $default_chef_path"
      prepare_chef_repo
      run_project "$run_for_type"
    ;;
    "OK" )
      log "Check if chef_repo_running before running = '$chef_repo_running' with install type '$run_for_type'"
      include_bashrc
      create_build_file "$build_file" "$run_for_type"
      if [ "$(echo "$run_for_type" | awk '{print tolower($0)}')" !=  "desktop" ]
      then
        run_internal_project
      fi
      log_title "Project $project_name finished to run"
    ;;
    "no_project_name" )
      new_chef_repo="$initialize_install_dir/automatic_chef_repositories"
      log_bold "Switching to chef_repo_path '$new_chef_repo'"
      switch_project "$new_chef_repo" "$run_for_type"
    ;;
    "root" )
      new_chef_repo="$chef_repo_path/automatic_chef_repositories"
      log_bold "Switching to chef_repo_path '$new_chef_repo'"
      create_directory "$new_chef_repo" sudo
      chown -R "$(id --user --name $USER)":"$(id --group --name $USER)" "$chef_repo_path"
      switch_project "$new_chef_repo" "$run_for_type"
    ;;
    * )
      log_title "Houston we got a problem (state is $state): installing on default path: $default_chef_path"
      yes_no_question "Could not validate project. Do you want to continue with default values? " use_default "switch_project '$default_chef_path' '$run_for_type'" "exit 10"
    ;;
  esac
}
export -f run_project

function copy_project()
{
  for file in ${file_list[@]}
  do
    log "Copying '$initialize_install_dir/$file' to '$1/$file'"
    if [ "$initialize_install_dir/$file" != "$1/$file" ]
    then
      create_directory "$(dirname $1/$file)"
      cp -f $initialize_install_dir/$file $1/$file
    fi
  done
}
export -f copy_project
