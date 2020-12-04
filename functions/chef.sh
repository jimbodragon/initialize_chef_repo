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
