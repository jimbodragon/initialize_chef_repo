# initialize_chef_repo

The goal of this project is to create a auto fully automate Infrastructure support with chef.

1. Fork this project for your own purpose

2. Folder ./data is to export all variables for your Infrastructure
  a) File ./data/git.sh serves to list the git submodule for your Infrastructure project
  b) File ./data/chef.sh gives the environment and recipe to build your Infrastructure
  b) File ./data/general.sh gives a name to your Infrastructure and the base url of the git to save/download by default

3. Folder ./functions/ is to export all require function to maintain a best practice with chef and git for developping your Infrastructure
  a) File ./functions/chef.sh provides function require to build your Infrastructure with Chef
  b) File ./functions/general.sh provides functions available to most of the unix system and load the all the data
  c) File ./functions/git.sh provides function to maintain a streamline into your development

4. Folder ./build is finished scripts to start building your Infrastructure
  a) File ./build/install_chef_infra.sh is a bash file to start chef (Require installation of Chef Workstation that can be run through ./build/start_$os_chef_workstation.sh)
  b) File ./build/test_environment.sh is to provide an INDEPENDENT scripting way to TEST your Infrastructure inside chef.
  c) File ./build/start* is to install chef workstation on the OS specification that will serve as main server of the Infrastructure (like ESX, Hyper-V, KVM, virtualBox, XenServer, etc...)
  d) File ./build/install_chef_infra.sh is a bash file to start the Chef process independent of the OS (as long as the os support Bash and the Environment Variables include Chef)

5. Folder ./initialize provide the way to clone the Infra project with his submodule or to initialize one for chef

6. The root folder of the project is made to download easily the initialize_initializator.sh script without git install on the machine.

7. Here is the magic: 'wget https://raw.githubusercontent.com/jimbodragon/initialize_chef_repo/master/initialize_initializator.sh && bash initialize_initializator.sh JimboDragon Test Dev QA SIT DR'

##Notes: If you are using a github acces to start, be sure that the starting machine has the access to fetch from your repository
