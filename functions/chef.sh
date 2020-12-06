#!/bin/bash##!/bin/bash#

source "$data_dir/$(basename "${BASH_SOURCE[0]}")"
source "$functions_dir/git.sh"

function install_chef_workstation()
{
  install_git
  if [ "$(which chef)" == "" ] || [ "$(chef -v | grep Workstation | cut -d ':' -f 2)" != " $chef_workstation_version" ]
  then
    echo "Downloading Chef Workstation"
    download $downloaded_chef_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb
    echo "Installing Chef Workstation"
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
    #cp -R $cookbook $2
  done
}
export -f berks_vendor_repo

function initializing_cookbook()
{
  cookbook_name=$1
  fork_from_public=$2
  git_url=$3
  if [ ! -d $cookbook_name/.git ]
  then
    initializing_project_submodule $cookbook_name $fork_from_public $git_url
    if [ ! -f $cookbook_name/metadata.rb ]
    then
      chef_generate cookbook $cookbook_name
      cd $cookbook_name
      commit_and_push "Initializing cookbook $cookbook_name"
      cd ..
    fi
  fi
}
export -f initializing_cookbook

function chef_command()
{
  install_chef_workstation
  echo "Executing chef command: chef $1 --chef-license accept $@"
  chef $1 --chef-license accept $@
}
export -f chef_command

function chef_generate()
{
  chef_command generate $@
}
export -f chef_generate

function executing_chef_clone()
{
  repository_type=$1 # $1 = Repository type: [cookbooks. libraries, resources]
  repository_name=$2 # $2 = Repository name
  fork_from_public=$3
  git_url=$4
  if [ ! -d $repository_type ]
  then
    create_directory $repository_type
  fi
  cd $repository_type
  case $repository_type in
    "cookbooks" | "libraries" | "resources" )
      initializing_cookbook $repository_name $fork_from_public $4
    ;;&
    "libraries" )
      cd $repository_name
      chef_generate helpers $repository_name
    ;;&
    "resources" )
      cd $repository_name
      chef_generate resource $repository_name
    ;;&
    "libraries" | "resources" )
      commit_and_push "Initializing $repository_type $repository_name"
      cd ..
    ;;
    "scripts" | "databag" | "environment" | "roles" | "nodes" | "generators" )
      initializing_project_submodule $repository_name $fork_from_public $git_url
    ;;
  esac
  cd ..
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
  create_directory "$1"
  cd "$1"
  chef_generate repo -r "$2"
  cd "$1/$2"

  create_directory $(basename $scripts_dir)
  create_directory $(basename $libraries_path)
  create_directory $(basename $resources_path)

  sed -i 's|# !cookbooks/chef_workstation|# !cookbooks/chef_workstation\\\n\\\ncookbooks/example\\\ndata_bags/example\\\nenvironments/example\\\nroles/example\\\nlibraries/example\\\nresources/example\\\nroles/example\\\ncookbooks/README.md\\\ndata_bags/README.md\\\nenvironments/README.md\\\nroles/README.md\\\nenvironments/example.json\\\nroles/example.json\\\nchecksums\\\nbackup\\\ncache\\\nlogs|g' .gitignore

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

  generate_new_chef_repo $new_chef_repo $new_project_name

  copy_project $new_install_path
  create_directory "$new_install_path/$(basename "$data_dir")"

  project_file="$new_install_path/$(basename "$data_dir")/project.sh"

  echo -e "\n\n\n\n\n\n\n\n--------------------------------------------------------------------------------------------------------\n\n"
  echo "project_file = $project_file"
  echo "git_branch = $git_branch => $new_git_branch"
  echo "environment = $environment => $new_environment"
  echo "git_main_project_name = $git_main_project_name => $new_git_main_project_name"
  echo "git_org = $git_org => $new_git_org"
  echo "git_baseurl = $git_baseurl => $new_git_baseurl"
  echo "git_user = $git_user => $new_git_user"
  echo "project_name = $project_name => $new_project_name"
  echo "http_git = $http_git => $new_http_git"
  echo "initialize_script_name = $initialize_script_name => $new_itialize_script_name"
  echo "initial_role = $initial_role => $new_initial_role"
  echo "initial_workstation_cookbook = $initial_workstation_cookbook => $new_initial_workstation_cookbook"
  echo "initial_current_dir = $initial_current_dir => $new_initial_current_dir"
  echo "default_chef_path = $default_chef_path => $new_chef_repo"
  echo "is_require_git_clone = $is_require_git_clone => $new_is_require_git_clone"
  echo -e "\n\n--------------------------------------------------------------------------------------------------------\n\n\n\n\n\n\n\n"

  sed -i "s|$git_branch|$new_git_branch|g" $project_file
  sed -i "s|$environment|$new_environment|g" $project_file
  sed -i "s|$git_main_project_name|$new_git_main_project_name|g" $project_file
  sed -i "s|$git_org|$new_git_org|g" $project_file
  sed -i "s|$git_baseurl|$new_git_baseurl|g" $project_file
  sed -i "s|$git_user|$new_git_user|g" $project_file
  sed -i "s|$project_name|$new_project_name|g" $project_file
  sed -i "s|$http_git|$new_http_git|g" $project_file
  sed -i "s|$initialize_script_name|$new_itialize_script_name|g" $project_file
  sed -i "s|$initial_role|$new_initial_role|g" $project_file
  sed -i "s|$initial_workstation_cookbook|$new_initial_workstation_cookbook|g" $project_file

  sed -i "s|$initial_current_dir|$new_initial_current_dir|g" $project_file
  sed -i "s|\$(pwd)|$new_initial_current_dir|g" $project_file

  sed -i "s|$chef_repo|$new_chef_repo|g" $project_file
  sed -i "s|$default_chef_path|$new_chef_repo|g" $project_file
  sed -i "s|/usr/local/chef/repo|$new_chef_repo|g" $project_file

  sed -i "s|export is_require_git_clone=0|export is_require_git_clone=$new_is_require_git_clone|g" $project_file

  echo "$new_install_path/$(basename "$install_dir")/source_project.sh"
}
export -f new_chef_infra

function ensure_default_attributes
{
  echo -e "\"default_attributes\": {\"chef_workstation_initialize\": {\"project_name\": $project_name, \"environments\": [$chef_environment], \"install_dir\": $install_dir, \"gitinfo\": {}, \"chef_initialized\": true}}"
}
export -f ensure_default_attributes

function project_json
{
  echo -e "{\"name\": \"$project_name\",\"description\": \"$project_description\",\"chef_type\": \"${1,,}\",\"json_class\": \"Chef::$1\",${ensure_default_attributes}, \"override_attributes\": {},\"run_list\": [\"$chef_run_list\"]}"
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
    echo "$3" > $json_file
  fi
}
export -f write_role_environment

function write_main_role
{
  write_role_environment "$role_path" "$project_name" "$project_role_json"
}
export -f write_main_role

function write_main_environment
{
  write_role_environment "$environments_path" "$environment" "$project_environment_json"
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
  initialize_data_file="$1/$2/scripts/$initialize_script_name/data/initialize.sh"
  source "$initialize_data_file"
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

  chef-solo --chef-license 'accept' --config $solo_file --override-runlist $chef_run_list --logfile "$log_path/chef_solo_$project_name_$environment.log"

}
export -f execute_chef_solo
