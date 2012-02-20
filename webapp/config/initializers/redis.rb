class NoRedis
  def delete_matched(key)
  end 
end

def redis
  if Rails.configuration.try(:action_view).try(:cache_template_loading)
    Thread.current[:redis] ||= ActiveSupport::Cache::RedisStore.new
  else
    NoRedis.new
  end
end
