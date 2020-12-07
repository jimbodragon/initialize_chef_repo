#!/bin/bash##!/bin/bash#

function install_chef_workstation()
{
  install_git
  if [ "$(which chef)" == "" ] || [ "$(chef -v | grep Workstation | cut -d ':' -f 2)" != " $chef_workstation_version" ]
  then
    log "Downloading Chef Workstation"
    download $downloaded_chef_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb
    log "Installing Chef Workstation"
    dpkg -i $downloaded_chef_file
  fi
}
export -f install_chef_workstation

function berks_vendor_all()
{
  berks_vendor_repo "$cookbook_path" "$1"
  berks_vendor_repo "$libraries_path" "$1"
  berks_vendor_repo "$resources_path" "$1"
}
export -f berks_vendor_all

function berks_vendor_repo()
{
  cookbook_folder=$1
  berks_vendor_folder=$2

  for cookbook in $(ls $cookbook_folder)
  do
    cd $cookbook_folder/$cookbook
    berks vendor $berks_vendor_folder > /dev/null
    cd $cookbook_folder
  done
}
export -f berks_vendor_repo

function chef_command()
{
  chef_command=$1
  shift
  chef_options=$@
  install_chef_workstation
  log "Executing chef command from $(pwd): chef $chef_command --chef-license accept $chef_options"
  chef $chef_command --chef-license accept $chef_options
}
export -f chef_command

function chef_generate()
{
  generate_command=$1
  shift
  generate_options=$@
  chef_command "generate $generate_command" $generate_options
}
export -f chef_generate

function chef_generate_repo()
{
  chef_generate repo -r $@
}
export -f chef_generate_repo

function initializing_project_submodule()
{
  repository_type=$1 # $1 = Repository type: [cookbooks. libraries, resources]
  repository_path=$2 # $2 = Repository name
  fork_from_public=$3
  git_url=$4

  repository_relative_path="$repository_type/$respository_name"

  if [ "$git_url" == "" ]
  then
    if [ "$fork_from_public" == "" ]
    then
      initializing_git_submodule "$git_user@$git_baseurl:$git_org/$repository_name.git" "$repository_relative_path"
    else
      initializing_git_submodule "$fork_from_public" "$repository_relative_path"
    fi
  else
    initializing_git_submodule "$git_url" "$repository_relative_path"
    if [ "$fork_from_public" != "" ]
    then
      merging_from_fork "$repository_relative_path" "$fork_from_public"
    fi
  fi
}
export -f initializing_project_submodule

function executing_chef_clone()
{
  repository_type=$1 # $1 = Repository type: [cookbooks. libraries, resources]
  repository_name=$2 # $2 = Repository name
  fork_from_public=$3
  git_url=$4

  clone_repo="$chef_repo_path/$repository_type"

  if [ ! -d "$clone_repo" ]
  then
    create_directory "$clone_repo"
  fi
  cd "$chef_repo_path"

  case $repository_type in
    "scripts" | "databag" | "environment" | "roles" | "nodes" | "generators" )
      initializing_project_submodule "$repository_type" "$repository_type/$repository_name" "$fork_from_public" "$git_url"
      cd "$clone_repo"
    ;;&
    "cookbooks" )
      chef_generate cookbook $repository_name
    ;;
    "libraries" )
      chef_generate helpers $repository_name
    ;;
    "resources" )
      chef_generate resource $repository_name
    ;;
  esac
}
export -f executing_chef_clone

function chef_import_submodule()
{
  for github_repo in "${git_repos[@]}"
  do
    cd $chef_repo
    eval $github_repo
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_import_submodule

function chef_update_submodule()
{
  for github_repo in "${git_repos[@]}"
  do
    cd $chef_repo
    eval $github_repo
    git submodule update --recursive "$type/$name"
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_update_submodule

function generate_new_chef_repo()
{
  log "Generating a new Chef repo at '$1' name '$2'"
  create_directory "$1"
  cd "$1"
  chef_generate_repo "$2"
  cd "$1/$2"

  create_directory $(basename $scripts_dir)
  create_directory $(basename $libraries_path)
  create_directory $(basename $resources_path)

  sed -i 's|# !cookbooks/chef_workstation|# !cookbooks/chef_workstation\n\ncookbooks/example\ndata_bags/example\nenvironments/example\nroles/example\nlibraries/example\nresources/example\nroles/example\ncookbooks/README.md\ndata_bags/README.md\nenvironments/README.md\nroles/README.md\nenvironments/example.json\nroles/example.json\nchecksums\nbackup\ncache\nlogs|g' .gitignore

  initialize_git "$git_branch"

  git add *
  git commit -m 'Initializing repo' > /dev/null 2>&1
}
export -f generate_new_chef_repo

function new_chef_infra()
{
  new_project_name="$1"
  new_git_branch="$2"
  new_environment="$3"
  new_git_main_project_name="$4"
  new_git_org="$5"
  new_git_baseurl="$6"
  new_git_user="$7"
  new_http_git="$8"
  new_itialize_script_name="$9"
  if [ "${10}" == "/" ]
  then
    new_chef_repo=${14}
  else
    new_chef_repo=${10}
  fi
  new_install_path="$new_chef_repo/$new_project_name/$(basename $scripts_dir)/$new_itialize_script_name"
  new_initial_role="${11}"
  new_initial_workstation_cookbook="${12}"
  new_initial_current_dir=${13}
  new_default_chef_path=${14}
  new_is_require_git_clone=${15}
  new_install_file_name=${16}

  log "$(generate_new_chef_repo $new_chef_repo $new_project_name)"

  log "$(copy_project $new_install_path)"
  log "$(create_directory "$new_install_path/$(basename "$data_dir")")"

  project_file="$new_install_path/$(basename "$data_dir")/project.sh"

  log_string=""

  log_string="project_file = $project_file"
  log_string="$log_String\ngit_branch = $git_branch => $new_git_branch"
  log_string="$log_String\nenvironment = $environment => $new_environment"
  log_string="$log_String\ngit_main_project_name = $git_main_project_name => $new_git_main_project_name"
  log_string="$log_String\ngit_org = $git_org => $new_git_org"
  log_string="$log_String\ngit_baseurl = $git_baseurl => $new_git_baseurl"
  log_string="$log_String\ngit_user = $git_user => $new_git_user"
  log_string="$log_String\nproject_name = $project_name => $new_project_name"
  log_string="$log_String\ninitialize_script_name = $initialize_script_name => $new_itialize_script_name"
  log_string="$log_String\ninitial_role = $initial_role => $new_initial_role"
  log_string="$log_String\ninitial_workstation_cookbook = $initial_workstation_cookbook => $new_initial_workstation_cookbook"
  log_string="$log_String\ninitial_current_dir = $initial_current_dir => $new_initial_current_dir"
  log_string="$log_String\ndefault_chef_path = $default_chef_path => $new_chef_repo"
  log_string="$log_String\nis_require_git_clone = $is_require_git_clone => $new_is_require_git_clone"
  log_string="$log_String\ninstall_file_name = $install_file_name => $new_install_file_name"

  log_title "$log_string"

  for parameter in "git_branch" "environment" "git_main_project_name" "git_org" "git_baseurl" "git_user" "project_name" "http_git" "initialize_script_name" "initial_role" "initial_workstation_cookbook" "initial_current_dir" "is_require_git_clone" "install_file_name"
  do
    change_project_parameter "$parameter" "$(eval "echo \"\$new_$parameter\"")" "$new_install_path"
  done

  change_chef_parameter "chef_repo" "$new_chef_repo" "$new_install_path"
  change_chef_parameter "default_chef_path" "$new_chef_repo" "$new_install_path"

  echo "$new_install_path/$(basename "$data_dir")/initialize.sh"
}
export -f new_chef_infra

function change_parameter()
{
  parameter_name=$1
  new_value=$2
  file_path=$3

  old_export_string="export $parameter_name=\"$(eval "echo \"\$$parameter_name\"")\""
  new_export_string="export $parameter_name=\"$new_value\""

  log "Changing value from '$old_export_string' to '$new_export_string'"

  sed -i "s|$old_export_string|$new_export_string|g" $file_path
}
export -f change_parameter

function change_project_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/project.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_project_parameter

function change_system_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/system.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_system_parameter

function change_initialize_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/initialize.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_initialize_parameter

function change_git_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/git.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_git_parameter

function change_general_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/general.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_general_parameter

function change_chef_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/chef.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_chef_parameter

function ensure_default_attributes
{
  echo "\"default_attributes\": {\"$chef_workstation_initialize]\": {\"project_name\": \"$project_name\", \"environments\": [\"$chef_environment\"], \"install_dir\": \"$install_dir\", \"gitinfo\": {}, \"chef_initialized\": true}}"
}
export -f ensure_default_attributes

function project_json
{
  echo "{\"name\": \"$project_name\",\"description\": \"$project_description\",\"chef_type\": \"${1,,}\",\"json_class\": \"Chef::$1\",$(ensure_default_attributes), \"override_attributes\": {},\"run_list\": [\"$chef_run_list\", \"recipe[$chef_workstation_initialize]\"]}"
}
export -f project_json

function project_role_json()
{
  project_json "Role"
}
export -f project_role_json

function project_environment_json
{
  project_json "Environment"
}
export -f project_environment_json

function write_role_environment
{
  json_file="$1/$2.json"
  if ! [ -f $json_file ]
  then
    echo -e "$3" > $json_file
  fi
}
export -f write_role_environment

function write_main_role
{
  write_role_environment "$role_path" "$project_name" "$(project_role_json)"
}
export -f write_main_role

function write_main_environment
{
  write_role_environment "$environment_path" "$environment" "$(project_environment_json)"
}
export -f write_main_environment

function write_main_role_environment
{
  write_main_role
  write_main_environment
}
export -f write_main_role_environment

function execute_chef_solo()
{
  create_directory $chef_repo_path
  create_directory $cookbook_path
  create_directory $libraries_path
  create_directory $resources_path
  create_directory $data_bag_path
  create_directory $environment_path
  create_directory $role_path
  create_directory $checksum_path
  create_directory $file_backup_path
  create_directory $file_cache_path
  create_directory $log_path
  create_directory $berks_vendor

  cat << EOS > $solo_file
checksum_path '$checksum_path'
cookbook_path [
                '$berks_vendor'
              ]
data_bag_path '$data_bag_path'
environment '$chef_environment'
environment_path '$environment_path'
file_backup_path '$file_backup_path'
file_cache_path '$file_cache_path'
#json_attribs nil
lockfile '$chef_repo_path/chef-solo.lock'
log_level :info
log_location STDOUT
node_name 'install_chef_infra'
#recipe_url 'http://path/to/remote/cookbook'
rest_timeout 300
role_path '$role_path'
#sandbox_path 'path_to_folder'
solo true
syntax_check_cache_path
umask 0022
#verbose_logging nil
EOS

  write_main_role_environment

  rm -rf "$berks_vendor"

  berks_vendor_all "$berks_vendor"

  log_bold "Starting run list = $chef_run_list"

  chef-solo --chef-license 'accept' --config $solo_file --override-runlist "role[$project_name]" --logfile "$log_path/chef_solo_$project_name_$environment.log"

}
export -f execute_chef_solo
