#!/bin/bash##!/bin/bash#

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"
source $current_dir/git.sh

function install_chef_workstation()
{
  install_git
  if [ "$(chef -v | grep Workstation | cut -d ':' -f 2)" != " $chef_workstation_version" ]
  then
    wget -O $download_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb
    dpkg -i $download_file
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

function chef_generate()
{
  chef_type_name=$1
  generate_option=$2
  echo "Generating $chef_type_name $generate_option"
  chef generate $chef_type_name $generate_option
}
export -f chef_generate

function executing_chef_clone()
{
  repository_type=$1 # $1 = Repository type: [cookbooks. libraries, resources]
  repository_name=$2 # $2 = Repository name
  fork_from_public=$3
  git_url=$4
  # echo "initializing_cookbook in $(pwd) for type $1 for cookbook $2"
  if [ ! -d $repository_type ]
  then
    mkdir $repository_type
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
  load_git_repos

  for github_repo in "${git_repos[@]}"
  do
    cd $chef_repo
    #echo "github_repo = $github_repo"
    eval $github_repo
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_import_submodule

function chef_update_submodule()
{
  load_git_repos

  for github_repo in "${git_repos[@]}"
  do
    cd $chef_repo
    #echo "github_repo = $github_repo"
    eval $github_repo
    git submodule update --recursive "$type/$name"
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_update_submodule

function new_chef_infra()
{
  new_project_name="$1"
  new_git_branch="$2"
  new_environment="$3"
  new_git_main_project_name="$4"
  new_git_org="$5"
  new_git_baseurl="$6"
  new_git_user="$7"
  new_http_git="$8/$git_org"
  new_install_path="$9/$new_project_name"
  new_itialize_script_name="${10}"
  new_initial_role="${11}"

  project_file="$new_install_path/$(get_relative_path "$data_dir/project.sh")"

  cp -r $chef_repo_path $new_install_path
  create_directory "$new_install_path/$(get_relative_path "$data_dir")"

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

  echo "New Chef Infra at $new_install_path"
  echo
}
export -f new_chef_infra

function ensure_default_attributes
{
  echo -e "\"default_attributes\": {\"chef_workstation_initialize\": {\"project_name\": $project_name, \"environments\": [$chef_environment], \"install_dir\": $install_dir, \"gitinfo\": {}, \"chef_initialized\": true}}"
}
export -f new_chef_infra

function project_json
{
  echo -e "{\"name\": \"$project_name\",\"description\": \"$project_description\",\"chef_type\": \"${1,,}\",\"json_class\": \"Chef::$1\",${ensure_default_attributes}, \"override_attributes\": {},\"run_list\": [\"$chef_run_list\"]}"
}

function project_role_json()
{
  project_json "Role"
}

function project_environment_json
{
  project_json "Environment"
}

function write_role_environment
{
  json_file="$1/$2.json"
  if ! [ -f $json_file ]
  then
    echo "$3" > $json_file
  fi
}

function write_main_role
{
  write_role_environment "$role_path" "$project_name" "$project_role_json"
}

function write_main_environment
{
  write_role_environment "$environments_path" "$environment" "$project_environment_json"
}

function write_main_role_environment
{
  write_main_role
  write_main_environment
}

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
