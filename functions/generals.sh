#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"
source $current_dir/chef.sh

function create_dir()
{
  folder_path=$1
  if [ ! -d $folder_path ]
  then
    mkdir $folder_path
  fi
}
export -f create_dir

function get_relative_path()
{
  if [ "$1" == "" ]
  then
    echo "Error to get relative path '$1'" > /dev/stderr
    exit 1
  fi
  case $(dirname $1) in
    $chef_repo_path )
      echo "${1#"$chef_repo_path"}"
    ;;
    *)
      get_relative_path $(dirname $1)
    ;;
  esac
}
export -f create_dir

function yes_no_question()
{
  message=$1
  return_variable_as_same_as_the_question_on_recursive_method=$2
  command_to_execute_if_yes=$3
  command_to_execute_if_no=$3
	read -p "$folder_path" "$variable_to_put_answer_to"
	eval "input=\$$2"
	case $input in
		"Y" | "y" | "Yes" | "yes" )
			$command_to_execute_if_yes
		;;
		"N" | "n" | "No" | "no" )
			$command_to_execute_if_no
		;;

		* )
			echo "Enter a valid yes/no"
			$return_variable_as_same_as_the_question_on_recursive_method
		;;

	esac
}
export -f yes_no_question

function validate_git_repo()
{
	yes_no_question "Be sure to have a git repository and a SSH key import to it. Do you want to continue? " validate_git_repo "" "exit 1"
}
export -f validate_git_repo
