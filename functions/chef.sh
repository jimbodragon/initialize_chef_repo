#!/bin/bash##!/bin/bash#

function get_chef_repo_path()
{
  "$(dirname $(dirname $initialize_install_dir))"
}
export -f get_chef_repo_path

function install_chef_workstation()
{
  install_git
  if [ "$(which chef)" == "" ] || [ "$(chef -v | grep Workstation | cut -d ':' -f 2)" != " $chef_workstation_version" ]
  then
    log "Downloading Chef Workstation"
    download $downloaded_chef_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb
    log "Installing Chef Workstation"
    sudo dpkg -i $downloaded_chef_file
  fi
  eval "$(chef shell-init bash)"
  export PATH="/opt/chefdk/embedded/bin:$PATH"
}
export -f install_chef_workstation

function berks_vendor()
{
  install_chef_workstation

  cd $1
  log "Berks vendoring $(basename $1) for $1 at $2"
  if [ ! -d $2 ]
  then
    log "Creating berks_vendor for $1 at $2 from $(pwd)"
    create_directory $2
  fi
  log "$(berks vendor $2 2>&1)"
}
export -f berks_vendor

function berks_vendor_all()
{
  cd $chef_repo_path

  debug_log "Berks Vendor all cookbooks, librairies and resources"

  berks_vendor_repo "$cookbook_path"
  berks_vendor_repo "$libraries_path"
  berks_vendor_repo "$resources_path"
}
export -f berks_vendor_all

function berks_vendor_repo()
{
  cookbooks_folder=$1
  debug_log "Berks Vendor for $cookbooks_folder"
  for cookbook in $(ls $cookbooks_folder)
  do
    if [ -d "$cookbooks_folder/$cookbook" ]
    then
      berks_vendor "$cookbooks_folder/$cookbook" "$berks_vendor_folder"
    fi
  done
}
export -f berks_vendor_repo

function chef_command()
{
  chef_command=$1
  shift
  chef_options=$@
  install_chef_workstation
  log "Executing chef command from $(pwd): chef $chef_command --chef-license accept $chef_options"
  chef $chef_command --chef-license accept $chef_options
}
export -f chef_command

function chef_generate()
{
  generate_command=$1
  shift
  generate_options=$@
  chef_command "generate $generate_command" $generate_options
}
export -f chef_generate

function chef_generate_repo()
{
  chef_generate repo -r $@
}
export -f chef_generate_repo

function initializing_project_submodule()
{
  repository_relative_path=$1 # $2 = Repository name
  fork_from_public=$2
  git_url=$3

  if [ "$git_url" == "" ]
  then
    if [ "$fork_from_public" == "" ]
    then
      log "initializing_git_submodule from Git Organisation $git_org"
      initializing_git_submodule "$git_user@$git_baseurl:$git_org/$repository_name.git" "$repository_relative_path"
    else
      log "initializing_git_submodule from fork $fork_from_public"
      initializing_git_submodule "$fork_from_public" "$repository_relative_path"
    fi
  else
    log "initializing_git_submodule from git $git_url"
    initializing_git_submodule "$git_url" "$repository_relative_path"
    if [ "$fork_from_public" != "" ]
    then
      merging_from_fork "$repository_relative_path" "$fork_from_public"
    fi
  fi
}
export -f initializing_project_submodule

function executing_chef_clone()
{
  repository_type=$1 # $1 = Repository type: [cookbooks. libraries, resources]
  repository_name=$2 # $2 = Repository name
  fork_from_public=$3
  git_url=$4

  clone_repo="$chef_repo_path/$repository_type"

  if [ ! -d "$clone_repo" ]
  then
    create_directory "$clone_repo"
  fi
  cd "$chef_repo_path"

  case $repository_type in
    "scripts" | "databag" | "environment" | "roles" | "nodes" | "generators" | "cookbooks" | "libraries" | "resources" )
      initializing_project_submodule "$repository_type/$repository_name" "$fork_from_public" "$git_url"
      log "Initializing project_submodule '$repository_type/$repository_name' '$fork_from_public' '$git_url'"
      read -p "Press 'ENTER' ro continue"
    ;;&
    "cookbooks" | "libraries" | "libraries" )
      chef_generate cookbook $repository_name
    ;;
  esac
}
export -f executing_chef_clone

function chef_import_submodule()
{
  for github_repo in "${git_repos[@]}"
  do
    cd $chef_path
    eval $github_repo
    log "Importing submodule $name of type $type => fork_from_public = $fork_from_public, git_url = $git_url"
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_import_submodule

function chef_update_submodule()
{
  for github_repo in "${git_repos[@]}"
  do
    cd $chef_path
    eval $github_repo
    git submodule update --recursive "$type/$name"
    executing_chef_clone "$type" "$name" "$fork_from_public" "$git_url"
  done
}
export -f chef_update_submodule

function generate_new_chef_repo()
{
  log "Generating a new Chef repo at '$1' name '$2'"
  create_directory "$1"
  cd "$1"
  chef_generate_repo "$2"
  cd "$1/$2"

  create_directory $(basename $scripts_dir)
  create_directory $(basename $libraries_path)
  create_directory $(basename $resources_path)
  create_directory $(basename $download_path)

  sed -i 's|# !cookbooks/chef_workstation|# !cookbooks/chef_workstation\n\ncookbooks/example\ndata_bags/example\nenvironments/example\nroles/example\nlibraries/example\nresources/example\nroles/example\ncookbooks/README.md\ndata_bags/README.md\nenvironments/README.md\nroles/README.md\nenvironments/example.json\nroles/example.json\nchecksums\nbackup\ncache\nlogs|g' .gitignore

  initialize_git "$git_branch"

  git add *
  git commit -m 'Initializing repo' > /dev/null 2>&1
}
export -f generate_new_chef_repo

function new_chef_infra()
{
  new_project_name="$1"
  new_git_branch="$2"
  new_environment="$3"
  new_git_main_project_name="$4"
  new_git_org="$5"
  new_git_baseurl="$6"
  new_git_user="$7"
  new_http_git="$8"
  new_initialize_script_name="$9"
  new_initial_role="${11}"
  new_initial_workstation_cookbook="${12}"
  new_initial_current_dir=${13}
  new_default_chef_path=${14}
  if [ "${10}" == "/" ]
  then
    new_chef_repo=$new_default_chef_path
  elif [ "${10}" == "" ]
  then
    new_chef_repo="$chef_path/$new_project_name"
  else
    new_chef_repo=${10}
  fi
  new_install_path="$new_chef_repo/$new_project_name/$(basename $scripts_dir)/$new_initialize_script_name"
  new_is_require_git_clone=${15}
  new_install_file_name=${16}
  new_initialize_git_org=${17}
  new_additionnal_environments=${18}

  log "$(generate_new_chef_repo $new_chef_repo $new_project_name)"

  log "$(copy_project $new_install_path)"
  log "$(create_directory "$new_install_path/$(basename "$data_dir")")"

  project_file="$new_install_path/$(basename "$data_dir")/project.sh"

  log_string=""

  log_string="project_file = $project_file"
  log_string="$log_String\ngit_branch = $git_branch => $new_git_branch"
  log_string="$log_String\nenvironment = $environment => $new_environment"
  log_string="$log_String\ngit_main_project_name = $git_main_project_name => $new_git_main_project_name"
  log_string="$log_String\ngit_org = $git_org => $new_git_org"
  log_string="$log_String\ngit_baseurl = $git_baseurl => $new_git_baseurl"
  log_string="$log_String\ngit_user = $git_user => $new_git_user"
  log_string="$log_String\nproject_name = $project_name => $new_project_name"
  log_string="$log_String\ninitialize_script_name = $initialize_script_name => $new_initialize_script_name"
  log_string="$log_String\additionnal_environments = $additionnal_environments => $new_additionnal_environments"
  log_string="$log_String\ninitial_role = $initial_role => $new_initial_role"
  log_string="$log_String\ninitial_workstation_cookbook = $initial_workstation_cookbook => $new_initial_workstation_cookbook"
  log_string="$log_String\ninitial_current_dir = $initial_current_dir => $new_initial_current_dir"
  log_string="$log_String\ndefault_chef_path = $default_chef_path => $new_chef_repo"
  log_string="$log_String\nis_require_git_clone = $is_require_git_clone => $new_is_require_git_clone"
  log_string="$log_String\ninstall_file_name = $install_file_name => $new_install_file_name"

  # log_title "$log_string"

  for parameter in "git_branch" "environment" "git_main_project_name" "git_org" "git_baseurl" "git_user" "project_name" "http_git" "initialize_script_name" "initial_role" "initial_workstation_cookbook" "initial_current_dir" "is_require_git_clone" "install_file_name" "initialize_git_org additionnal_environments"
  do
    change_project_parameter "$parameter" "$(eval "echo \"\$new_$parameter\"")" "$new_install_path"
  done

  change_chef_parameter "chef_repo" "$new_chef_repo" "$new_install_path"
  change_chef_parameter "default_chef_path" "$new_chef_repo" "$new_install_path"

  echo "$new_install_path/$(basename "$data_dir")/initialize.sh"
}
export -f new_chef_infra

function change_parameter()
{
  parameter_name=$1
  new_value=$2
  file_path=$3

  old_export_string="export $parameter_name=\"$(eval "echo \"\$$parameter_name\"")\""
  new_export_string="export $parameter_name=\"$new_value\""

  debug_log "Changing value from '$old_export_string' to '$new_export_string'"

  sed -i "s|$old_export_string|$new_export_string|g" $file_path
}
export -f change_parameter

function change_project_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/project.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_project_parameter

function change_system_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/system.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_system_parameter

function change_initialize_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/initialize.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_initialize_parameter

function change_git_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/git.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_git_parameter

function change_general_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/general.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_general_parameter

function change_chef_parameter()
{
  parameter_name=$1
  new_value=$2
  new_install_path=$3

  project_file="$new_install_path/$(basename "$data_dir")/chef.sh"

  change_parameter "$1" "$2" "$project_file"
}
export -f change_chef_parameter

function ensure_default_attributes
{
  echo "\"default_attributes\": {\"$initial_workstation_cookbook\": {\"project_name\": \"$project_name\", \"environments\": [\"$chef_environment\"], \"install_dir\": \"$chef_path\", \"gitinfo\": {}, \"chef_initialized\": true}, \"virtualbox\":{\"default_interface\": \"eth0\"},\"chef-git-server\":{\"user_data_bag\": \"chef_git_server_user\", \"ssh_keys_data_bag\": \"ssh_keys\"}}"
}
export -f ensure_default_attributes

function project_json
{
  echo "{\"name\": \"$1\",\"description\": \"$project_description\",\"chef_type\": \"${2,,}\",\"json_class\": \"Chef::$2\",$(ensure_default_attributes), \"override_attributes\": {},\"run_list\": [\"recipe[$initial_workstation_cookbook]\"]}"
}
export -f project_json

function project_role_json()
{
  project_json $1 "Role"
}
export -f project_role_json

function project_environment_json
{
  project_json $1 "Environment"
}
export -f project_environment_json

function write_role_environment
{
  json_file="$1/$2.json"
  if ! [ -f $json_file ]
  then
    echo -e "$3" > $json_file
  fi
}
export -f write_role_environment

function write_main_role
{
  write_role_environment "$role_path" "$project_name" "$(project_role_json $project_name)"
}
export -f write_main_role

function write_main_environment
{
  write_role_environment "$environment_path" "$chef_environment" "$(project_environment_json $chef_environment)"
}
export -f write_main_environment

function write_main_role_environment
{
  write_main_role
  write_main_environment
}
export -f write_main_role_environment

function prepare_chef_repo()
{
  log "Preparing chef repo $chef_repo_path"
  create_directory $chef_repo_path
  create_directory $cookbook_path
  create_directory $libraries_path
  create_directory $resources_path
  create_directory $data_bags_path
  create_directory $environment_path
  create_directory $role_path
  create_directory $checksum_path
  create_directory $file_backup_path
  create_directory $file_cache_path
  create_directory $log_path
  create_directory $berks_vendor_folder
  create_directory "$data_bags_path/cookbook_secret_keys"
  create_directory "$data_bags_path/passwords"

  log "Directory '$chef_repo_path' created as result $(ls -alh $chef_repo_path)"

  cd "$chef_repo_path"

  write_main_role_environment

  log_level="info"
  if [ "$DEBUG_LOG" != "" ] && [ $DEBUG_LOG -eq 1 ]
  then
    log_level="debug"
  fi


  if [ ! -f "$solo_file" ]
  then
    cat << EOS > $solo_file
checksum_path '$checksum_path'
cookbook_path [
              '$berks_vendor_folder'
            ]
data_bags_path '$data_bags_path'
environment '$chef_environment'
environment_path '$environment_path'
file_backup_path '$file_backup_path'
file_cache_path '$file_cache_path'
#json_attribs nil
lockfile '$chef_repo_path/chef-solo.lock'
log_level :$log_level
# log_location STDOUT
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
  fi

  rm -rf "$berks_vendor_folder/*"
  rm -rf "$chef_repo_path/Berksfile.lock"

  cat << EOF > "$chef_repo_path/Berksfile"
source 'https://supermarket.chef.io'
cookbook 'chef-git-server', '~> 1.0.0', github: "jimbodragon/chef-git-server"
cookbook 'infra_chef', '~> 0.1.0', github: "jimbodragon/infra_chef"
cookbook 'infraClass', '~> 0.1.0', github: "jimbodragon/infraClass"
cookbook 'virtualbox', '~> 4.0.0', github: "jimbodragon/virtualbox"
# cookbook 'chef_workstation_initialize', '~> 0.1.0', github: "jimbodragon/chef_workstation_initialize"

# cookbook 'chef-git-server', '~> 1.0.0', git: "git@github.com:jimbodragon/chef-git-server.git"
# cookbook 'infra_chef', '~> 0.1.0', git: "git@github.com:jimbodragon/infra_chef.git"
# cookbook 'infraClass', '~> 0.1.0', git: "git@github.com:jimbodragon/infraClass.git"
# cookbook 'virtualbox', '~> 4.0.0', git: "git@github.com:jimbodragon/virtualbox.git"
cookbook 'chef_workstation_initialize', '~> 0.1.0', git: "git@github.com:jimbodragon/chef_workstation_initialize.git"

# cookbook 'chef-git-server', '~> 1.0.0', path: "/usr/local/chef/repo/Example/cookbooks/chef-git-server"
# cookbook 'infra_chef', '~> 0.1.0', path: "/usr/local/chef/repo/Example/cookbooks/infra_chef"
# cookbook 'infraClass', '~> 0.1.0', path: "/usr/local/chef/repo/Example/infraClass"
# cookbook 'virtualbox', '~> 4.0.0', path: "/usr/local/chef/repo/Example/cookbooks/virtualbox"
# cookbook 'chef_workstation_initialize', '~> 0.1.0', path: "/usr/local/chef/repo/Example/cookbooks/chef_workstation_initialize.git"
EOF

cat << EOF > "$chef_repo_path/knife.rb"
current_dir = File.dirname(__FILE__)

# log_level                :info
# log_location             STDOUT
# node_name                '$project_name'
# secret			 '28MgvGOtbXRQkQQ6lw22'
#
# #api_version   1
# #validation_client_name   'devops'
# #validation_key           '#{current_dir}/devops.pem'
#
# knife[:chef_repo_path] = '/home/jproven3/GitProject/jimbo_local/JimboDragon'
# knife[:vsphere_user] = "domain\\username"
# knife[:vsphere_pass] = ""
#
# knife[:data_bags_path] = "#{knife[:chef_repo_path]}/data_bags/"
# knife[:data_path] = "#{knife[:chef_repo_path]}/data/"
# knife[:env_path] = "#{knife[:chef_repo_path]}/environments/"
# knife[:role_path] = "#{knife[:chef_repo_path]}/roles/"
#
# syntax_check_cache_path  "#{current_dir}/syntax_check_cache"
# #cookbook_path            ["#{current_dir}/../chefRepo/cookbooks", "#{current_dir}/../GitProject/yp_chefProject/cookbooks", "#{current_dir}/../chefRepo/supermarket_cookbooks", "#{current_dir}/../GitProject/github_project", "/home/jproven3/GitProject/yp_chefProject/cookbooks"]
# cookbook_path		  ["#{knife[:chef_repo_path]}/cookbooks", "#{knife[:chef_repo_path]}/libraries", "#{knife[:chef_repo_path]}/resources",]
#
# puts "chef_repo_path = #{knife[:chef_repo_path]}"
# knife[:editor]="/bin/nano"
#
# puts "PROGRAM_NAME = #{$PROGRAM_NAME}"
# puts "ARGV = #{$ARGV}"
# if File.basename($PROGRAM_NAME).eql?('chef-cli') || File.basename($PROGRAM_NAME).eql?('knife')
#   case ARGV[0].to_s
#   when 'generate'
#     puts "Usind own generator"
#     chefcli.generator_cookbook "#{knife[:chef_repo_path]}/generators/jimbo_generator"
#     chefcli.generator.copyright_holder "Jimbo Dragon"
#     chefcli.generator.license   "mit"
#     chefcli.generator.email     "jimbo_dragon@hotmail.com"
#   when 'supermarket'
#     puts "Editing supermarket"
#     node_name 'jprovencher'
#     client_key File.join(knife[:chef_repo_path], '.chef/jprovencher.pem')
#   end
# end
#
# #knife[:authentication_protocol_version] = '1.3'
#
# #knife[:vault_mode] = 'client'
# #knife[:vault_admins] = [ 'xxxxx', 'yyyyy', 'zzzzz']
#
#
# #chef_server_url     'https://chef.dev.ypg.com/organizations/devops'
# #client_key    '/home/jproven3/.chef/jproven3.pem'
#
# puts "Finish loading knife.rb on #{current_dir}"





# acl_path:                             /root/acls
# allowed_automatic_attributes:
# allowed_default_attributes:
# allowed_normal_attributes:
# allowed_override_attributes:
# always_dump_stacktrace:               false
# authentication_protocol_version:      1.1
# automatic_attribute_blacklist:
# automatic_attribute_whitelist:
# blocked_automatic_attributes:
# blocked_default_attributes:
# blocked_normal_attributes:
# blocked_override_attributes:
# cache_options:
#   path: /root/.chef/syntaxcache
# cache_path:                           /root/.chef/local-mode-cache
# checksum_path:                        /root/.chef/local-mode-cache/checksums
# chef_guid:
# chef_guid_path:                       /root/.chef/chef_guid
# chef_repo_path:                       /root
# chef_server_root:                     chefzero://localhost:1
# chef_server_url:                      chefzero://localhost:1
# chef_zero:
#   enabled:    true
#   host:       localhost
#   osc_compat: false
#   port:       #<Enumerator:0x000000000136d318>
#   single_org: chef
# chefcli:
# chefdk:
# clear_gem_sources:
# client_d_dir:                         /root/.chef/client.d
# client_fork:
# client_key:
# client_key_contents:
# client_key_path:                      /root/client_keys
# client_path:                          /root/clients
# client_registration_retries:          5
# color:                                true
# config_d_dir:                         /root/.chef/config.d
# config_dir:                           /root/.chef/
# config_file:
# container_path:                       /root/containers
# cookbook_artifact_path:               /root/cookbook_artifacts
# cookbook_path:
#   /usr/local/chef/repo/Jimbodragon/cookbooks
#   /usr/local/chef/repo/Jimbodragon/libraries
#   /usr/local/chef/repo/Jimbodragon/resources
# cookbook_sync_threads:                10
# count_log_resource_updates:           false
# data_bag_decrypt_minimum_version:     0
# data_bag_encrypt_version:             3
# data_bags_path:                        /root/data_bags
# data_collector:
#   mode:             both
#   organization:     chef_solo
#   raise_on_failure: false
#   server_url:
#   token:
# default_attribute_blacklist:
# default_attribute_whitelist:
# deployment_group:
# diff_disabled:                        false
# diff_filesize_threshold:              10000000
# diff_output_threshold:                1000000
# disable_event_loggers:                false
# download_progress_interval:           10
# enable_reporting:                     true
# enable_reporting_url_fatals:          false
# enable_selinux_file_permission_fixup: true
# encrypted_data_bag_secret:
# enforce_default_paths:                false
# enforce_path_sanity:                  false
# environment_path:                     /root/environments
# event_handlers:
# event_loggers:
# exception_handlers:
# ez:                                   false
# file_atomic_update:                   true
# file_backup_path:                     /root/.chef/local-mode-cache/backup
# file_cache_path:                      /root/.chef/local-mode-cache/cache
# file_staging_uses_destdir:            auto
# fips:                                 false
# follow_client_key_symlink:            false
# force_formatter:                      false
# force_logger:                         false
# formatter:                            null
# formatters:
# group:
# group_path:                           /root/groups
# group_valid_regex:                    (?-mix:^[^-+~:,\t\r\n\f\0]+[^:,\t\r\n\f\0]*$)
# http_disable_auth_on_redirect:        true
# http_retry_count:                     5
# http_retry_delay:                     5
# internal_locale:                      C.UTF-8
# interval:
# json_attribs:
# knife:
#   hints:
#
# listen:                               false
# local_key_generation:                 true
# local_mode:                           true
# lockfile:                             /root/.chef/local-mode-cache/cache/chef-client-running.pid
# log_level:                            info
# log_location:                         STDERR
# minimal_ohai:                         false
# named_run_list:
# no_lazy_load:                         true
# node_name:                            root
# node_path:                            /root/nodes
# normal_attribute_blacklist:
# normal_attribute_whitelist:
# ohai:
#   critical_plugins:
#   disabled_plugins:
#   hints_path:       /etc/chef/ohai/hints
#   log_level:        auto
#   log_location:     #<IO:0x000000000097b7d8>
#   optional_plugins:
#   plugin:
#   plugin_path:
#     /opt/chef-workstation/embedded/lib/ruby/gems/2.7.0/gems/ohai-16.6.5/lib/ohai/plugins
#     /etc/chef/ohai/plugins
#   run_all_plugins:  false
#   shellout_timeout: 30
# ohai_segment_plugin_path:             /root/.chef/ohai/cookbook_plugins
# once:
# override_attribute_blacklist:
# override_attribute_whitelist:
# pid_file:
# policy_document_native_api:           true
# policy_group:
# policy_group_path:                    /root/policy_groups
# policy_name:
# policy_path:                          /root/policies
# profile:
# recipe_url:
# repo_mode:                            hosted_everything
# report_handlers:
# resource_unified_mode_default:        false
# rest_timeout:                         300
# role_path:                            /root/roles
# ruby_encoding:                        UTF-8
# rubygems_cache_enabled:               false
# rubygems_url:
# run_lock_timeout:
# script_path:
# show_download_progress:               false
# silence_deprecation_warnings:
# solo:                                 false
# solo_d_dir:                           /root/.chef/solo.d
# solo_legacy_mode:                     false
# splay:
# ssh_agent_signing:                    false
# ssl_ca_file:
# ssl_ca_path:
# ssl_client_cert:
# ssl_client_key:
# ssl_verify_mode:                      verify_peer
# start_handlers:
# stream_execute_output:                false
# syntax_check_cache_path:              /root/.chef/syntaxcache
# target_mode:
#   enabled:  false
#   protocol: ssh
# treat_deprecation_warnings_as_errors: false
# trusted_certs_dir:                    /root/.chef/trusted_certs
# umask:                                18
# user:
# user_home:                            /root
# user_path:                            /root/users
# user_valid_regex:                     (?-mix:^[^-+~:,\t\r\n\f\0]+[^:,\t\r\n\f\0]*$)
# validation_client_name:               chef-validator
# validation_key:
# validation_key_contents:
# verbose_logging:                      true
# verify_api_cert:                      true
# why_run:                              false
# windows_service:
#   watchdog_timeout: 7200
# zypper_check_gpg:                     true


chef_repo_path                       "$chef_repo_path"
cookbook_path [
  "$cookbook_path",
  "$libraries_path",
  "$resources_path"
]
data_bags_path                        "$data_bags_path"
environment_path                     "$environment_path"
log_level                            "$log_level"
node_name                            "$project_name"
node_path                            "$nodes_dir"
policy_group_path                    "$policy_group_dir"
policy_path                          "$policy_dir"
role_path                            "$role_path"
EOF

# cat << EOF > "$data_bags_path/passwords/www-data.json"
# {
#   "id": "www-data",
#   "password": "TestStrongPassword",
#   "rawpassword": "TestRawStringPassword",
#   "sha512_encrypted_password": "\$6\$ScATBxYnGu2g1yMl\$0V/5CaCH5ipDihPDTYo3FGQHdd6Dwtip/BKYjR2h3zx04.BtvVy9vz/jZVymZXXgFttpErR22DYzo7DuTt0lt0"
# }
# EOF

cat << EOF > "$file_cache_path/password_www-data.rb"
#!/opt/chef-workstation/embedded/bin/ruby

require 'json'

file_path = ARGV[0]

virtualbox_web_user = JSON.parse(File.read(file_path))
virtualbox_web_user['password'] = 'TestStrongPassword'

File.write(file_path, JSON.dump(virtualbox_web_user))
EOF

cat << EOF > "$file_cache_path/cookbook_virtual.rb"
#!/opt/chef-workstation/embedded/bin/ruby

require 'json'

file_path = ARGV[0]

secret_virtualbox_cookbook = JSON.parse(File.read(file_path))
chef_git_server_user['$USER'] = {"ssh_keys": [File.read("$HOME/.ssh/id_rsa.pub")]}

File.write(file_path, JSON.dump(chef_git_server_user))
echo "{\"id\": \"virtualbox\", \"secret\": \"\$(openssl rand -base64 512 | tr -d '\r\n')\"}" > \$1
EOF

cat << EOF > "$file_cache_path/chef_git_server_user.rb"
#!/opt/chef-workstation/embedded/bin/ruby

require 'json'

file_path = ARGV[0]

chef_git_server_user = JSON.parse(File.read(file_path))
chef_git_server_user['private_keys'] = [File.read("$HOME/.ssh/id_rsa.pub")]

File.write(file_path, JSON.dump(chef_git_server_user))
EOF

  chmod 775 $file_cache_path/password_www-data.rb
  chmod 775 $file_cache_path/cookbook_virtual.rb
  chmod 775 $file_cache_path/chef_git_server_user.rb

  log "Creating encrypted data bag at current dir $(pwd)"
  create_databag "chef_git_server_user" $USER "$file_cache_path/chef_git_server_user.rb"
  create_databag cookbook_secret_keys virtualbox "$file_cache_path/cookbook_virtual.rb"
  create_encrypted_databag passwords www-data cookbook_secret_keys virtualbox secret "$file_cache_path/password_www-data.rb"

  berks_vendor_self
}
export -f prepare_chef_repo

function berks_vendor_self()
{
  berks_vendor "$chef_repo_path" "$berks_vendor_folder"
  berks_vendor_all "$berks_vendor_folder"
}
export -f berks_vendor_self

function execute_chef_solo()
{
  log_bold "Starting run list = $chef_run_list"

  sudo chef-solo --chef-license 'accept' --config $solo_file --override-runlist "$chef_run_list" --logfile "$log_path/chef_solo_$project_name_$environment.log"
  chown_project
}
export -f execute_chef_solo

function build_project()
{
  log_bold "Starting run list = $chef_run_list"

  converge_project
}
export -f build_project
