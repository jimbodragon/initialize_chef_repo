#!/bin/bash

export git_main_project_name='jimbodragon_chef_repo'
export git_org='jimbodragon'
export git_baseurl='github.com'
export git_user='git'
export git_fork_upstream_name='chef-public-cookbook'
#export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}/.." )" >/dev/null 2>&1 && pwd )"
export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
export initialize_chef_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && git rev-parse --show-toplevel || pwd )"
export functions_dir="$initialize_chef_dir/functions"
export initialize_dir="$initialize_chef_dir/initialize"
export git_repos_file="$initialize_chef_dir/git_repos.sh"

source $functions_dir/git.sh
source $functions_dir/chef.sh

function create_dir()
{
  if [ ! -d $1 ]
  then
    mkdir $1
  fi
}
export -f create_dir

function yes_no_question()
{
	read -p "$1" "$2"
	eval "input=\$$2"
	case $input in
		"Y" | "y" | "Yes" | "yes" )
			$3
		;;
		"N" | "n" | "No" | "no" )
			$4
		;;

		* )
			echo "Enter a valid yes/no"
			$2
		;;

	esac
}
export -f yes_no_question

function validate_git_repo()
{
	yes_no_question "Be sure to have a git repository and a SSH key import to it. Do you want to continue? " keep_continue "" "exit 1"
}
export -f validate_git_repo
