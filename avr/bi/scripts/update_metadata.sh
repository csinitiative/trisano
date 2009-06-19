#!/bin/sh

# Path on the file system where the BI server was installed
export BI_SERVER_PATH=/usr/local/pentaho/server/biserver-ce

# URL that the BI server can is running on (needed to publish updates)
export BI_PUBLISH_URL=http://localhost:8080/pentaho/RepositoryFilePublisher

# Publishing password. This is not tied to a user, but is configured
# in $BI_SERVER_PATH/pentaho-solutions/system/publisher_config.xml
export BI_PUBLISH_PASSWORD=password

# User credentials for an admin on the BI server. (also needed for
# publishing)
export BI_USER_NAME=joe
export BI_USER_PASSWORD=password

# move to the script's dir because we can't change where pentaho looks
# for some things.
cd $BI_SERVER_PATH/pentaho-solutions/TriSano

java -cp $BI_SERVER_PATH/lib/jruby-complete-1.2.0.jar org.jruby.Main \
    $BI_SERVER_PATH/pentaho-solutions/TriSano/update_metadata.rb

