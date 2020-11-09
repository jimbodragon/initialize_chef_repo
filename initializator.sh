#!/bin/bash

initial_command="${BASH_SOURCE[0]} $@"

if [ "$(for git in $(sudo apt-cache madison git | cut -d '|' -f 2); do sudo dpkg -l | grep git | grep $git; done | head -n 1 | awk '{print $1}')" != "ii" ]
then
  #apt-get -y update && sudo apt-get -y upgrade
  apt-get -y install git
fi

os='ubuntu'
os_version='18.04'
chef_workstation_version='20.10.168'
chef_client_version='16.6.14'
chef_version=$chef_client_version
download_file='/tmp/chef_install.deb'
project_name=$1
shift
for chef_environment in $@
do
  if [ "$chef_environment_json" == "" ]
  then
    chef_environment_json="\"$chef_environment\""
  else
    chef_environment_json="$chef_environment_json, \"$chef_environment\""
  fi
done

# Chef workstation
if [ ! -f chef_workstation_installed ]
then
  wget -O $download_file https://packages.chef.io/files/stable/chef-workstation/$chef_workstation_version/$os/$os_version/chef-workstation_$chef_workstation_version-1_amd64.deb && touch chef_workstation_installed
  dpkg -i $download_file
fi

mkdir cookbooks > /dev/null 2>&1

cd cookbooks
git clone git@github.com:jimbodragon/chef_workstation_initialize.git > /dev/null 2>&1
cd chef_workstation_initialize
berks vendor ../cookbooks
cd ../..
cat << EOS > solo.rb
cookbook_path ['cookbooks']
EOS

chef_solo_command="chef-solo --chef-license 'accept' --json-attributes node.json --config solo.rb --override-runlist 'recipe[chef_workstation_initialize]'"

cat<<EOS > node.json
{
  "chef_workstation_initialize": {
    "project_name": "project_name",
    "environments": [$chef_environment_json],
    "initial_command": "$initial_command",
    "install_dir": "$(pwd)",
    "chef_solo_command": "$chef_solo_command"
  }
}
EOS

echo "chef_solo_command = $chef_solo_command"
eval "$chef_solo_command"
