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
      cmd="mkdir -p $1"
      if [ "$1" == "$default_chef_path" ]
      then
        sudo $cmd
        chown_folder "$default_chef_path"
      else
        $cmd
      fi

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
  if [ -f $1 ] && [ "$(cat $1 | wc -l)" -gt "0" ] && [ "$3" != "-force" ]
  then
    log_bold "Skipping file as it exists $2 to $1 with flag $3"
    echo > /dev/null
  elif [ -f $1 ] && [ "$(cat $1 | wc -l)" -eq "0" ] || [ "$3" == "-force" ]
  then
    log_bold "File exist but not downloaded correctly: $1 or force (flag $3 detected)"
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
  download "$local_path" "$raw_url" "$2"
}
export -f download_github_raw

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download_github_raw "$file" $1
  done
}
export -f download_project

function source_all_require_files()
{
  for file in ${file_list[@]}
  do
    log "Source file $initialize_install_dir/$file"
    source "$initialize_install_dir/$file"
  done
  redefine_data
}
export -f source_all_require_files

function download_latest_files() {
  log_bold "Downloading latest files $chef_repo_path | $project_name"
  download_project $1
}
export -f download_latest_files

function update_files() {
  log_bold "Downloading latest files $chef_repo_path | $project_name"
  download_latest_files $1
  source_all_require_files
}
export -f update_files

function wait_for_command()
{
  start_internal_timer=$(date +%s)
  let "expected_restart=$start_internal_timer+(($4*3600)+($3*3600)+($2*60)+$1)"

  while [ $expected_restart -gt $(date +%s) ]
  do
    let "duration=$(date +%s)-$start_internal_timer"
    if [ $duration -gt 0 ]
    then
      log "Next run at $(date -d @$expected_restart) for $(printf "%02d:%02d:%02d\n" $((duration/3600)) $((duration%3600/60)) $((duration%60)))"
      log "Last run at $(date -d @$start_internal_timer)"
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
  is_good=$(validate_project)

  case $is_good in
    "OK" )
      log "Clear all chef_repo_path: $chef_repo_path | $project_name"
      for file in ${file_list[@]}
      do
        log "Removing file $initialize_install_dir/$file"
        rm -f "$initialize_install_dir/$file"
      done
      delete_directory_project
      rm -rf $chef_repo_path
      ;;
    * )
      log "Cannot clear the project at $chef_repo_path of cause $is_good"
      ;;
  esac
}
export -f clear_project

function download_and_run_project()
{
  cd $initial_current_dir
  download_project
  log "Running command: 'bash --norc --noprofile $initialize_install_dir/install.sh $project_name $additionnal_environments'"
  bash --norc --noprofile "$install_file_name" "$project_name" "$additionnal_environments"
}
export -f download_and_run_project

function ord() {
  LC_CTYPE=C printf '%d' "'$1"
}
export -f ord

function valide_main_chef_repo()
{
  if [ "$chef_path" == "/" ]
  then
    log_bold "chef_path cannot be '/'"
    echo -n "root"
  else
    valide_chef_repo_root
  fi
}
export -f valide_main_chef_repo

function valide_chef_repo_name()
{
  if [ "$(basename $chef_repo_path)" != "$project_name" ]
  then
    log_bold "chef_repo_path must contain the project_name: '$chef_repo_path'"
    echo -n "no_project_name"
  else
    valide_solofile
  fi
}
export -f valide_chef_repo_name

function valide_chef_repo_root()
{
  if [ "$chef_repo_path" == "/" ]
  then
    log_bold "chef_repo_path cannot be '/'"
    echo -n "root"
  else
    valide_chef_repo_home
  fi
}
export -f valide_chef_repo_root

function valide_chef_repo_home()
{
  if [ "$chef_repo_path" == "/home" ]
  then
    log_bold "chef_repo_path cannot be '/home'"
    echo -n "home"
  else
    valide_chef_repo_name
  fi
}
export -f valide_chef_repo_home

function valide_berksfile()
{
  if [ ! -f "$chef_repo_path/Berksfile" ]
  then
    log_bold "No Berksfile in : '$chef_repo_path'"
    echo -n "no_berksfile"
  else
    echo -n "OK"
  fi
}
export -f valide_berksfile

function valide_solofile()
{
  if [ ! -f "$solo_file" ]
  then
    log_bold "No '$solo_file' in : '$chef_repo_path'"
    echo -n "no_solo_file"
  else
    valide_berksfile
  fi
}
export -f valide_solofile

function valide_sourced()
{
  if [ "$(type redefine_project_data 2>&1 | grep "is a function")" != "redefine_project_data is a function" ]
  then
    log_bold "redefine_project_data function not recognize '$chef_repo_is_good'"
    echo -n "not_loaded"
  else
    valide_main_chef_repo
  fi
}
export -f valide_sourced

function valide_downloaded_files()
{
  is_downloaded='yes'
  for file in ${file_list[@]}
  do
    if [ ! -f "$initialize_install_dir/$file" ]
    then
      log_bold "file is missing \"$initialize_install_dir/$file\""
      is_downloaded="no"
      break
    fi
  done

  if [ "$is_downloaded" == "yes" ]
  then
    valide_sourced
  else
    echo -n "not_downloaded"
  fi
}
export -f valide_downloaded_files

function valide_leave_requested()
{
  if [ -f "$initialize_chef_repo_stopfile" ]
  then
    log_bold "Quitting project '$chef_repo_path'"
    echo -n "quit"
  else
    valide_downloaded_files
  fi
}
export -f valide_leave_requested

function validate_project()
{
  valide_leave_requested
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

function reinitialize_parameters()
{
  initialize_parameters "$source_file"
  redefine_data
}
export -f reinitialize_parameters

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
    download_latest_files "$1"
  fi
}
export -f prepare_project

function run_internal_project()
{
  log_title "log_title Running chef $project_name"
  check_and_install procmail

  if [ ! -f $initialize_chef_repo_lockfile ]
  then
    touch $initialize_chef_repo_lockfile

    log_title "Fetching latest source for project $project_name"
    update_files "-force"

    run_project
  else
    log_title "Install $project_name as fresh with environments $additionnal_environments"
    cd $chef_repo_path
    # wait_for_project_command "knife config show --all"

    rm -rf "$chef_repo_path/Berksfile.lock"
    berks_vendor_self
    execute_chef_solo
    rm -f $initialize_chef_repo_lockfile
    log_title "Able to change run_internal_project function dynamically: $project_name"
  fi
}
export -f run_internal_project

function switch_project() {
  new_project_folder="$1/$project_name/$(basename $scripts_dir)/$initialize_script_name"
  new_source_file="$new_project_folder/$data_dir_name/$(basename ${BASH_SOURCE[0]})"
  log_bold "Switching to new_source_file '$new_source_file': Old one is '$source_file'"
  copy_project "$new_project_folder"
  reinitialize_parameters "$new_source_file"
  redefine_data
  rename_project $project_name
  log_bold "Reexecuting the project"
  run_project
  log_title "Project $project_name finished to run"
}
export -f switch_project

function run_project()
{
  state="$(validate_project)"

  case "$state" in
    "no_solo_file" | "no_berksfile" )
      log_title "Error as $state: Preparing the chef repo: $default_chef_path"
      prepare_chef_repo
      run_project "$run_for_type"
    ;;
    "OK" )
      log "Check if chef_repo_running before running = '$chef_repo_running' with install type '$run_for_type'"
      include_bashrc
      create_build_file "$build_file" "$run_for_type"
      case "$(echo "$run_for_type" | awk '{print tolower($0)}')" in
      "server" | "" )
        run_internal_project
        ;;
      "deamon" )
        wait_for_project_command "run_internal_project"
      ;;
      "desktop" )
        log "Desktop type Installed successfully"
        ;;
      "*" )
        log "Unknown run_for_type $run_for_type at $chef_repo_path"
        log "Run internal project anyway"
        run_internal_project
        ;;
      esac
      log_title "Project $project_name finished to run for type $run_for_type from $chef_repo_path"
    ;;
    "no_project_name" )
      log "Change the project location that fit with his name $project_name"
      new_chef_repo="$chef_path/automatic_chef_repositories"
      move_project "$new_chef_repo"
    ;;
    "root" )
      log "Set location to default '$default_chef_path' instead of $chef_path"
      create_directory "$default_chef_path"
      move_project "$default_chef_path"
    ;;
    "home" )
      log "Set location to default '$default_chef_path' instead of $chef_path"
      create_directory "$default_chef_path"
      move_project "$default_chef_path"
    ;;
    "not_downloaded" )
      log "File not downloaded at $chef_repo_path"
      update_files
      run_project
    ;;
    "not_loaded" )
      log "File not loaded at $chef_repo_path"
      source_all_require_files
      run_project
    ;;
    "quit" )
      log "Leaving the Deamon project $project_name"
      run_for_type="quit_$run_for_type"
    ;;
    * )
      log_title "Houston we got a problem (state is $state): installing on default path: $default_chef_path"
      yes_no_question "Could not validate project. Do you want to continue with default values? " use_default "move_project '$default_chef_path' '$run_for_type'" "exit 10"
    ;;
  esac
}
export -f run_project

function chown_folder()
{
  sudo chown -R "$(id --user --name $USER)":"$(id --group --name $USER)" "$1"
}
export -f chown_folder

function chown_project()
{
  chown_folder "$chef_repo_path"
}
export -f chown_project

function copy_project()
{
  for file in ${file_list[@]}
  do
    if [ -f "$initialize_install_dir/$file" ]
    then
      log "Copying '$initialize_install_dir/$file' to '$1/$file'"
      if [ "$initialize_install_dir/$file" != "$1/$file" ]
      then
        create_directory "$(dirname $1/$file)"
        cp -f $initialize_install_dir/$file $1/$file
      fi
    fi
  done
}
export -f copy_project

function move_project()
{
  if [ "$1" != "$chef_path" ]
  then
    new_project_folder="$1/$project_name/$(basename $scripts_dir)/$initialize_script_name"
    new_source_file="$new_project_folder/$data_dir_name/$file_name"
    log_bold "Switching to new_source_file '$new_source_file': Old one is '$source_file'"
    touch "$initialize_chef_repo_stopfile"
    initialize_parameters "$new_source_file"
    reinitialize_parameters
    log_bold "Reexecuting the project from $1"
  fi
  run_project
}
export -f move_project
