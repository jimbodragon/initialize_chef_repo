#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$(dirname $current_dir)/data/$(basename "${BASH_SOURCE[0]}")"
source $current_dir/chef.sh

function get_relative_path()
{
  parent_folder=$(dirname $1)
  file_base="$(basename $1)"
  case "$1" in
    "" )
      echo "Error to get relative path '$1': Argument empty" > /dev/stderr
      exit 1
      ;;
    "/" )
      echo "Error to get relative path '$1': reach system root (/)" > /dev/stderr
      echo "$1"
      ;;
    * )
      for project_folder in "$chef_repo_path" "$cookbook_path" "$libraries_path" "$resources_path" "$data_bag_path" "$environment_path" "$role_path" "$scripts_dir" "$initialize_install_dir" "$initialize_install_dir" "$functions_dir" "$build_dir" "$data_dir" "$log_dir" "$install_dir"
      do
        echo "get relative path of '$1' compare with '$project_folder'" > /dev/stderr
        if [ "$1" == "$project_folder" ]; then
          relative_project_folder="${project_folder#"$chef_repo_path"}"
          rel_path="$relative_project_folder/${1#"$project_folder"}"
          break
        fi
      done

      if [ "$rel_path" == "" ]
      then
        echo "$(get_relative_path $parent_folder)/$file_base"
      else
        echo "Relative path is $rel_path" > /dev/stderr
        echo "$rel_path"
      fi
      ;;
  esac
}
export -f get_relative_path

function create_build_file()
{
  new_build_file="$build_dir/$1$extension"
  # if [ ! -f $new_build_file ]
  # then
    cat << EOF  >$new_build_file
current_dir="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "\$(dirname \$current_dir)/install/source_project.sh"
install_chef_workstation
#new_chef_infra "\$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path" "\$initial_role" "\$initial_workstation_cookbook"
new_chef_infra "$project_name" "\$git_branch" "\$environment" "\$git_main_project_name" "\$git_org" "\$git_baseurl" "\$git_user" "\$http_git" "\$install_path" "\$initial_role" "\$initial_workstation_cookbook"
cd \$cookbook_path
git clone git@github.com:jimbodragon/chef_workstation_initialize.git > /dev/null 2>&1
convert_initialize_to_cookbook
execute_chef_solo \$current_dir "\$project_name"
EOF
  # fi
}

function convert_initialize_to_cookbook()
{
  for file in ${file_list[@]}
  do
    case "$(basename $(dirname $file))" in
      "$data_dir_name" )
        cd $cookbook_path/$initial_workstation_cookbook
        chef_generate template -s $file $(basename $file)
      ;;
      *)
        chef_generate file -s $file $(basename $file)
      ;;
    esac
  done
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
