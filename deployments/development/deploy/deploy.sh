#!/bin/sh

# This is a user friendly name for the deployment target
target_name="Production"

# git branch or tag you wish to deploy
target_tag="master"

# Path used to stage code.
local_ce_staging_path="/tmp/trisano_deploy"

# Path where TriSano is stored locally
local_ce_code_path="~/code/trisano"

# Hostname of the server you would normally use to access
# via SSH. You may want to add an entry to ~/.ssh/config
# to set user or proxies
ssh_host=$7

# This is last part of the path you used for script/prepare_plugins
# For example, if you used script/prepare_plugins ../deployments/production
# the deployment_descriptor would be "production"
deployment_descriptor="production"

# This is the path the source code is expected to be deployed to
remote_deployment_target_path="/opt/trisano"

# In order for the cache warming script to execute, the live url
# of the site is given here, along with ports and proxied paths.
live_url="https://demo.trisano.com:8080/production"

# After the deployment is done, return us back here.
original_path=$PWD

# Because the deployment descriptor is always the same as the 
# capistrano configuration file, we can reuse this variable here.
cap_deploy_prefix=$deployment_descriptor

# This can be calculated from the values above.
deployment_descriptor_path="$local_ce_staging_path/deployments/$deployment_descriptor"

echo "*************************************"
echo "*************************************"
read -r -p "Are you sure you are ready to deploy version *$target_tag* to *$target_name*? [Y/n] " response

case $response in
  [Y]) 

    echo ""
    echo ""
  
    echo "Clearing local CE staging area $local_ce_staging_path"
    rm -rf $local_ce_staging_path

    echo "Cloning trisano-ce to staging path"
    git clone file://$local_ce_code_path $local_ce_staging_path
    if [ $? -ne 0 ]
    then
      echo "Unable to clone."
      exit 1
    fi
    
    echo "Checking out trisano-ce @ $target_tag"
    cd $local_ce_staging_path
    git checkout -f $target_tag
    if [ $? -ne 0 ] 
    then
      echo "Unable to checkout trisano-ce @ $target_tag".
      exit 1
    fi

    
    echo "Setting up plugins for $target_name"
    cd $local_ce_staging_path/webapp
    script/prepare_plugins $deployment_descriptor_path
    
    echo "Deploying"
    cap $cap_deploy_prefix deploy

    echo "Backing up DB"
    cap $cap_deploy_prefix deploy:dump_db

    echo "Migrating DB"
    cap $cap_deploy_prefix deploy:migrate

    echo "Clean up old releases"
    cap $cap_deploy_prefix deploy:cleanup

    echo "Clearing cache"
    ssh $ssh_host "redis-cli KEYS '*' | xargs redis-cli DEL"

    echo "Warming cache (process will run in background)"
    ssh $ssh_host "cd $remote_deployment_target_path/current; RAILS_ENV=production bundle exec rake cache:warm[$live_url,100] --trace" &
    
    cd $original_path
    git tag -a -m "$USER deployed $target_tag to $target_name at `date -u`" "deployed-to-$ssh_host-`date -u +%Y-%m-%d_%H-%M`"

  ;;
esac


