require 'redis'

REDIS_CONFIG = YAML.load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
config = REDIS_CONFIG[Rails.env.to_sym].symbolize_keys
$redis = Redis::Namespace.new("robot", redis: Redis.new(config))
# To clear out the db before each test
# $redis.flushdb if Rails.env = "test"
