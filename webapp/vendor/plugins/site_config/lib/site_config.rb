SITE_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/site_config.yml")).with_indifferent_access

def reload_site_config
  SITE_CONFIG.replace YAML::load(File.open("#{RAILS_ROOT}/config/site_config.yml")).with_indifferent_access
end

def config_option(p, env = RAILS_ENV)
  config_options(env)[p]
end

def config_options(env = RAILS_ENV)
  raise "No configuration for environment \"#{env}\"" unless env_config = SITE_CONFIG[env]
  super_env = env_config[:inherit] ? config_options(env_config[:inherit]) : {}
  super_env.merge(env_config).with_indifferent_access
end
