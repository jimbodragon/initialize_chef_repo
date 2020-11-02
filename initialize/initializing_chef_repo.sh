#!/bin/bash

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$current_dir/../functions/git.sh

git_clone_main_project
cd ..
chef generate repo -r --chef-license accept jimbodragon_chef_repo

cd jimbodragon_chef_repo
mkdir scripts
cat $0 > scripts/$(basename $0)

cat << EOF > scripts/install_chef-infra.sh
#!/bin/bash

chef_path="/var/\$(basename \$0 | awk -F '.sh' '{print \\\$1}')"
cookbook_path='\$chef_path/cookbooks'
checksum_path='\$chef_path/checksums'
data_bag_path='\$chef_path/data_bags'
environment_path='\$chef_path/environments'
file_backup_path='\$chef_path/backup'
file_cache_path='\$chef_path/cache'
role_path='\$chef_path/roles'

cd \$cookbook_path
git clone git@github.com:jimbodragon/jimbodragon_chef_repo.git


cat << EOS > solo.rb
checksum_path '\$checksum_path'
cookbook_path [
               '\$cookbook_path'
              ]
data_bag_path '\$data_bag_path'
environment 'production'
environment_path '\$environment_path'
file_backup_path '\$file_backup_path'
file_cache_path '\$file_cache_path'
json_attribs nil
lockfile nil
log_level :info
log_location STDOUT
node_name 'mynode.example.com'
#recipe_url 'http://path/to/remote/cookbook'
rest_timeout 300
role_path '\$role_path'
#sandbox_path 'path_to_folder'
solo true
syntax_check_cache_path
umask 0022
verbose_logging nil
EOS

chef-solo -c solo.rb -r 'recipe[infra_chef]'
EOF

cat << EOS > scripts/start_ubuntu_chef_server.sh
#!/bin/bash

### Install chef to start chef-solo

os='ubuntu'
os_version='18.04'
chef_version='20.10.168'
download_file='/tmp/chef_workstation_install.deb'

sudo apt-get update && sudo apt-get upgrade

if [ "\$(for git in \$(sudo apt-cache madison git | cut -d '|' -f 2); do sudo dpkg -l | grep git | grep \$git; done | head -n 1 | awk '{print \$1}')" != "ii" ]
then
  sudo apt-get install git
fi


wget -o \$download_file https://downloads.chef.io/thankyou/workstation?download=https://packages.chef.io/files/stable/chef-workstation/\$chef_version/\$os/\$os_version/chef-workstation_\$chef_version-1_amd64.deb

dpkg -i \$download_file

sudo bash install_chef_infra.sh

EOS

git add scripts/*
git commit -m 'Initializong repo'

load_cookbooks

git add cookbooks
git add libraries
git add resources
git commit -m 'Initializing cookbooks'

git push
