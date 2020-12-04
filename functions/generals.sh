#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"
source $current_dir/chef.sh

function create_directory()
{
  folder_path=$1
  if [ ! -d $folder_path ]
  then
    mkdir $folder_path
  fi
}
export -f create_directory

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
export -f get_relative_path

function download_github_raw()
{
  raw_url="$http_git/$project_name/$git_branch"
  script_relative_path="$(echo $1 | awk -F "$initialize_install_dir" '{print $2}')"
  downloadurl="$raw_url$script_relative_path"
  wget --quiet -O "$1" "$downloadurl"
  chmod a+x "$1"
}

function create_build_file()
{
  new_build_file="$build_dir/$1$extension"
  if [ ! -f $new_build_file ]
  then
    cat << EOF  >$new_build_file
current_dir="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "\$(dirname \$current_dir)/functions/initialize.sh"
install_chef_workstation
#new_chef_infra "\$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path"
new_chef_infra "$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path"
cd \$cookbook_path
git clone git@github.com:jimbodragon/chef_workstation_initialize.git > /dev/null 2>&1
execute_chef_solo \$current_dir "\$project_name"
EOF
  fi
}

function create_directory_project()
{
  create_directory "$scripts_dir"
  create_directory "$functions_dir"
  create_directory "$initialize_dir"
  create_directory "$build_dir"
  create_directory "$data_dir"
  download_github_raw "$data_dir/generals.sh"
  source $data_dir/generals.sh
  create_directory "$log_dir"
  create_directory "$install_dir"
}

function download_project()
{
  create_directory_project

  for file in ${file_list[@]}
  do
    download_github_raw "$file"
  done
}

function prepare_project()
{
  create_directory_project
  download_project
}

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
