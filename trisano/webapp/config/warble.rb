# Monkeypatch: http://www.nabble.com/Re%3A-Why-does-Warbler-requires-a-db-to-build--p19504132.html
# Turn off Rails auto-detection which invokes the environment task and requires a DB connection 
class Warbler::Config; def auto_detect_rails; true; end; end

# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # Temporary directory where the application is staged
  # config.staging_dir = "tmp/war"

  # Application directories to be included in the webapp.
  config.dirs = %w(app config lib vendor tmp)

  # Additional files/directories to include, above those in config.dirs
  # config.includes = FileList["db"]

  # Additional files/directories to exclude

  # Additional Java .jar files to include.  Note that if .jar files are placed
  # in lib (and not otherwise excluded) then they need not be mentioned here
  # JRuby and Goldspike are pre-loaded in this list.  Be sure to include your
  # own versions if you directly set the value
  # config.java_libs += FileList["lib/java/*.jar"]
  config.java_libs.reject! {|lib| lib =~ /jruby-complete|goldspike/ }

  # Loose Java classes and miscellaneous files to be placed in WEB-INF/classes.
  # config.java_classes = FileList["target/classes/**.*"]

  # One or more pathmaps defining how the java classes should be copied into
  # WEB-INF/classes. The example pathmap below accompanies the java_classes
  # configuration above. See http://rake.rubyforge.org/classes/String.html#M000017
  # for details of how to specify a pathmap.
  # config.pathmaps.java_classes << "%{target/classes/,}"

  # Gems to be packaged in the webapp.  Note that Rails gems are added to this
  # list if vendor/rails is not present, so be sure to include rails if you
  # overwrite the value
  # config.gems = ["activerecord-jdbc-adapter", "jruby-openssl"]
  # config.gems << "tzinfo"
  config.gems = ["hoe", "hpricot", "rest-open-uri", "postgres-pr", "logging", "json-jruby", "rubyzip"]
  #config.gems = ["hoe", "hpricot", "rest-open-uri", "postgres-pr", "logging", "rubyzip", 'jdbc-postgres', 'activerecord-jdbc-adapter', 'activerecord-jdbcpostgresql-adapter']
  config.gems['rails'] = "2.0.2"

  # Include gem dependencies not mentioned specifically
  config.gem_dependencies = true

  # Files to be included in the root of the webapp.  Note that files in public
  # will have the leading 'public/' part of the path stripped during staging.
  # config.public_html = FileList["public/**/*", "doc/**/*"]

  # Name of the war file (without the .war) -- defaults to the basename
  # of RAILS_ROOT
  config.war_name = "trisano"

  # True if the webapp has no external dependencies
  config.webxml.standalone = true

  # Location of JRuby, required for non-standalone apps
  # config.webxml.jruby_home = <jruby/home>

  # Value of RAILS_ENV for the webapp
  #config.webxml.rails_env = 'development'
  #config.webxml.rails_env = ENV['RAILS_ENV'] ||= 'development'
  config.webxml.rails.env = ENV['RAILS_ENV'] ||= 'development'

  
  # Whether or not to turn basicauth on
  config.webxml.basicauth = ENV['basicauth'] ||= 'false'

  # Control the pool of Rails runtimes
  # (Goldspike-specific; see README for details)
  #config.webxml.pool.maxActive = ENV['max'] ||= '10'
  #config.webxml.pool.minIdle = ENV['min'] ||= '4'
  # config.webxml.pool.checkInterval = 0
  # config.webxml.pool.maxWait = 30000

  # Control the pool of Rails runtimes. Leaving unspecified means
  # the pool will grow as needed to service requests. It is recommended
  # that you fix these values when running a production server!
  config.webxml.jruby.min.runtimes = ENV['min_runtimes'] ||= '3'
  config.webxml.jruby.max.runtimes = ENV['max_runtimes'] ||= '10'
  config.webxml.jruby.runtime.timeout.sec = '5'

  # JNDI data source name
  # config.webxml.jndi = 'jdbc/rails'
end
