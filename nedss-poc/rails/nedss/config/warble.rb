# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # Temporary directory where the application is staged
  # config.staging_dir = "tmp/war"

  # Application directories to be included in the webapp.
  config.dirs = %w(app config lib log vendor tmp)

  # Additional files/directories to include, above those in config.dirs
  # config.includes = FileList["db"]

  # Additional files/directories to exclude
  # config.excludes = FileList["lib/tasks/*"]

  # Additional Java .jar files to include.  Note that if .jar files are placed
  # in lib (and not otherwise excluded) then they need not be mentioned here
  # JRuby and Goldspike are pre-loaded in this list.  Be sure to include your
  # own versions if you directly set the value
  # config.java_libs += FileList["lib/java/*.jar"]
  config.java_libs.reject! {|lib| lib =~ /jruby-complete|goldspike/ }

  # Gems to be packaged in the webapp.  Note that Rails gems are added to this
  # list if vendor/rails is not present, so be sure to include rails if you
  # overwrite the value
  # config.gems = ["ActiveRecord-JDBC", "jruby-openssl"]
  # config.gems << "tzinfo"

#  config.gems = ["rails", "activesupport", "activeresource", "activerecord", "actionpack", "actionmailer", "activerecord-jdbc-adapter", "chronic", "hoe", "hpricot", "jruby-openssl", "rest-open-uri", "postgres-pr"]

#  config.gems = ["rails", "activesupport", "activeresource", "activerecord", "actionpack", "actionmailer", "activerecord-jdbc-adapter", "chronic", "hoe", "jruby-openssl", "rest-open-uri", "postgres-pr"]

config.gems = ["rails", "activesupport", "activeresource", "activerecord", "actionpack", "actionmailer", "activerecord-jdbc-adapter", "chronic", "hoe", "hpricot", "rest-open-uri", "postgres-pr","acts_as_reportable","ruport"]

# Include all gems which are used by the web application
# TODO Circle back to this - simpler way to configure gems rather than having to set each manuall
# See http://wiki.jruby.org/wiki/Warbler
#require "#{RAILS ROOT}/config/boot"
#BUILD_GEMS = %w(warbler rake rcov)
#for gem in Gem.loaded_specs.values
#  next if BUILD_GEMS.include?(gem.name)
#  config.gems[gem.name] = gem.version.version
#end

  # Include gem dependencies not mentioned specifically
  config.gem_dependencies = true

  # Files to be included in the root of the webapp.  Note that files in public
  # will have the leading 'public/' part of the path stripped during staging.
  # config.public_html = FileList["public/**/*", "doc/**/*"]

  # Name of the war file (without the .war) -- defaults to the basename
  # of RAILS_ROOT
  # config.war_name = "mywar"

  # True if the webapp has no external dependencies
  config.webxml.standalone = true

  # Location of JRuby, required for non-standalone apps
  # config.webxml.jruby_home = <jruby/home>

  # Value of RAILS_ENV for the webapp
  config.webxml.rails_env = 'development'

  # Control the pool of Rails runtimes
  # (Goldspike-specific; see README for details)
  config.webxml.pool.maxActive = 10
  config.webxml.pool.minIdle = 4
  # config.webxml.pool.checkInterval = 0
  # config.webxml.pool.maxWait = 30000

  # JNDI data source name
  # config.webxml.jndi = 'jdbc/rails'
end
