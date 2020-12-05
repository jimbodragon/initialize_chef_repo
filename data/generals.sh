#!/bin/bash

echo "include generals.sh"

export git_fork_upstream_name='chef-public-cookbook'

file_list=(
  "$initialize_dir/initializing_chef_repo.sh"
  "$initialize_dir/git_clone_project.sh"
  "$functions_dir/initialize.sh"
  "$functions_dir/generals.sh"
  "$functions_dir/git.sh"
  "$functions_dir/chef.sh"
  "$data_dir/generals.sh"
  "$data_dir/git.sh"
  "$data_dir/chef.sh"
  "$data_dir/initialize.sh"
  "$data_dir/project.sh"
  "$data_dir/system.sh"
  "$build_dir/$project_name$extension"
  "$scripts_dir/$file_name"
)
