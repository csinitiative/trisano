class NoRedis
  def delete_matched(key)
  end 
end

def redis
  if RAILS_ENV == "production"
    Thread.current[:redis] ||= ActiveSupport::Cache::RedisStore.new
  else
    NoRedis.new
  end
end
