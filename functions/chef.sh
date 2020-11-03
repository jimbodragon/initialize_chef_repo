
export chef_environment='development'
export chef_run_list='role[zentyal_chef_infra]'

function berks_vendor_repo()
{
  for cookbook in $(ls $1)
  do
    cd $1/$cookbook
    berks vendor $2
    cd $1
    #cp -R $cookbook $2
  done
}
