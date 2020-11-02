#!/bin/bash

export git_main_project_name='jimbodragon_chef_repo'
export git_org='jimbodragon'
export git_baseurl='github.com'
export git_user='git'
export git_fork_upstream_name='chef-public-cookbook'
export main_repo_dir="$( cd "$( dirname "${BASH_SOURCE[0]}/.." )" >/dev/null 2>&1 && pwd )"
export functions_dir="$( cd "$main_repo_dir/functions" >/dev/null 2>&1 && pwd )"
export initialize_dir="$( cd "$main_repo_dir/initialize" >/dev/null 2>&1 && pwd )"
export cookbooks_file="$main_repo_dir/cookbooks.sh"

$functions_dir/git.sh

function create_dir()
{
  if [ ! -d $1 ]
  then
    mkdir $1
  fi
}

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

function validate_git_repo()
{
	yes_no_question "Be sure to have a git repository. Do you want to continue? " keep_continue "" "exit 1"
}
