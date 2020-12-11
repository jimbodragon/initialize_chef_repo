#!/bin/bash

function rename_project()
{
  log_subtitle "Renaming project from $project_name to $1"
  export project_name=$1
  new_source="$(new_chef_infra "$1" "$git_branch" "$environment" "$git_main_project_name" "$git_org" "$git_baseurl" "$git_user" "$http_git" "$initialize_script_name" "$chef_path" "$initial_role" "$initial_workstation_cookbook" "$initial_current_dir" "$default_chef_path" "$is_require_git_clone" "$install_file_name" "$initialize_git_org" "$additionnal_environments")"
  debug_log "rename_project => new_source = '$new_source'"
  source "$new_source"
  redefine_data
  chef_import_submodule
}
export -f rename_project

function check_and_install()
{
  if [ "$(for package in $(sudo apt-cache madison $1 | cut -d '|' -f 2); do sudo dpkg -l | grep $1 | grep $package; done | head -n 1 | awk '{print $1}')" != "ii" ]
  then
    log "Installing $1"
    apt-get install $1
  fi
}
export -f install_chef_workstation

function create_build_file()
{
  new_build_file="$1"
  if [ ! -f $new_build_file ]
  then
    cat << EOF  > $new_build_file
#!/bin/bash
current_dir="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "\$(dirname \$current_dir)/data/initialize.sh"
source "\$functions_dir/initialize.sh"
run_project
EOF
  fi
  chmod u+x $new_build_file
}
export -f create_build_file

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
export -f convert_initialize_to_cookbook

function include_bashrc()
{
  if [ "$(grep "source $data_dir/initialize.sh" ~/.bashrc)" == "" ]
  then
    yes_no_question "Do you want to include the script in the bash shell? " "include_bashrc" "echo -e \"source $functions_dir/initialize.sh\\nsource $data_dir/initialize.sh\" >> ~/.bashrc" ""
  fi
}
export -f include_bashrc

function get_github_netrc()
{
  if [ ! -f ~/.netrc ] || [ "$(grep "machine github.com" ~/.netrc)" == "" ]
  then
    read -p "Insert your personnal GitHub account to allow Berkshelf at downloading cookbook from github: " "github_user"
    read -sp "Insert password: " "github_password"

    if [ "$github_password" != "" ]
    then
      cat << EOF >> ~/.netrc
machine github.com
login $github_user
password $github_password
EOF
    fi
  fi
}
export -f get_github_netrc

function yes_no_question()
{
  message=$1
  return_variable_as_same_as_the_question_on_recursive_method=$2
  command_to_execute_if_yes=$3
  command_to_execute_if_no=$4
	read -p "$message" "$2"
	eval "input=\$$2"
	case $input in
		"Y" | "y" | "Yes" | "yes" )
			eval "$command_to_execute_if_yes"
		;;
		"N" | "n" | "No" | "no" )
			eval "$command_to_execute_if_no"
		;;

		* )
			log "Enter a valid yes/no"
			$return_variable_as_same_as_the_question_on_recursive_method
		;;

	esac
}
export -f yes_no_question

function validate_git_repo()
{
	yes_no_question "Be sure to have a git repository and a SSH key import to it. Do you want to continue? " "validate_git_repo" "" "exit 1"
}
export -f validate_git_repo
