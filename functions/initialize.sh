#!/bin/bash
# Script to execute to initialize a fresh new chef repository

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"
source $install_dir/source_project.sh

function create_directory()
{
  if [ ! -d "$1" ]
  then
    mkdir -p "$1"
  fi
}
export -f create_directory

function relative_path()
{
  rel_path="$(echo "$1"| awk -F "$scripts_dir" '{print $2}')"
  return $rel_path
}
export -f relative_path

function download()
{
  raw_url="$http_git/$project_name/$git_branch"
  script_relative_path="$(echo $1 | awk -F "$scripts_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  wget --quiet -O "$1" "$downloadurl"
  chmod a+x "$1"
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
  create_directory "$install_dir"
}
export -f create_directory_project

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download "$file"
  done
}
export -f download_project

function prepare_project()
{
  create_directory_project
  download_project
}
export -f prepare_project

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
