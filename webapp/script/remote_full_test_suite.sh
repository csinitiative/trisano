#!/bin/sh

set -e

target_tag="master"

original_path="$PWD"

local_ce_staging_path="/tmp/trisano.test"
local_ee_staging_path="/tmp/trisano-ee.test"

local_ce_code_path="$HOME/code/trisano"
local_ee_code_path="$HOME/code/trisano-ee"


echo "*************************************"
read -r -p "Are you sure you are ready to run all tests for *$target_tag*? [Y/n] " response

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
    
    echo "Clearing EE staging area $local_ee_staging_path"
    rm -rf $local_ee_staging_path
    
    echo "Cloning trisano-ee to staging pathectory"
    git clone file://$local_ee_code_path $local_ee_staging_path
    if [ $? -ne 0 ]
    then
      echo "Unable to clone."
      exit 1
    fi
 
    echo "Checking out trisano-ee @ $target_tag"
    cd $local_ee_staging_path
    git checkout -f $target_tag
    if [ $? -ne 0 ] 
    then
      echo "Unable to checkout trisano-ee @ $target_tag".
      exit 1
    fi


    echo "Setting up .rvmrc"
    cp $local_ce_code_path/webapp/.rvmrc $local_ce_staging_path/webapp/.rvmrc
    sed -i 's/trisano/trisano_test/g' $local_ce_staging_path/webapp/.rvmrc 


    echo "Setting up plugins for $target_name"
    cd $local_ce_staging_path/webapp
    script/prepare_plugins $deployment_descriptor_path

    echo "Installing gems"
    bundle install --local

    echo "Setting up log path"
    mkdir $local_ce_staging_path/webapp/log 

    echo "Setting site config"
    cp $local_ce_code_path/webapp/config/site_config.yml $local_ce_staging_path/webapp/config/site_config.yml 

    echo "Setting seperate test db"
    cp $local_ce_code_path/webapp/config/database.yml $local_ce_staging_path/webapp/config/database.yml 
    sed -i 's/trisano/trisano_test/g' $local_ce_staging_path/webapp/config/database.yml 

    echo "Switching ports for Selenium and web server"
    sed -i 's/4444/4445/g' features/support/enhanced.rb features/support/enhanced_support.sh features/support/enhanced_support_stop.sh
    sed -i 's/8080/8081/g' features/support/enhanced.rb features/support/enhanced_support.sh features/support/enhanced_support_stop.sh

    echo "Switching ports for Xvfb"
    sed -i 's/:99/:98/g' features/support/enhanced_support.sh features/support/enhanced_support_stop.sh


    echo "Stopping enhanced environment"
    ./features/support/enhanced_support_stop.sh

    echo "Reset DB"
    time bundle exec rake db:reset

    echo "Running specs, tail log/spec.log"
    time bundle exec rake spec > log/spec.log 2>&1

    echo "Running standard features, tail log/standard_features.log"
    time bundle exec rake features > log/standard_features.log 2>&1

    echo "Setting up enhanced support infrastructure"
    ./features/support/enhanced_support.sh

    echo "Running enhanced features, tail log/enhanced_features.log"
    time bundle exec rake enhanced_features > log/enhanced_features.log 2>&1

;;
esac
