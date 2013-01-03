#!/bin/sh


echo "*************************************"
read -r -p "Are you sure you are ready to run all tests? [Y/n] " response

case $response in
  [Y]) 

    echo "Stopping enhanced environment"
    ./script/enhanced_support_stop.sh

    echo "Reset DB"
    time bundle exec rake db:reset

    echo "Running specs, tail log/spec.log"
    time bundle exec rake spec > log/spec.log 2>&1

    echo "Running standard features, tail log/standard_features.log"
    time bundle exec rake features > log/standard_features.log 2>&1

    echo "Setting up enhanced support infrastructure"
    ./script/enhanced_support.sh

    echo "Running enhanced features, tail log/enhanced_features.log"
    time bundle exec rake enhanced_features > log/enhanced_features.log 2>&1

;;
esac
