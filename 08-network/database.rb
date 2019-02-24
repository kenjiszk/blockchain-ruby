require 'redis'

class Database
  def initialize
    @redis = Redis.new(host: ENV['REDIS_HOST'], port: 6379, db: 08)
  end

  def save(key, data)
    @redis.set key, serialize(data)
  end

  def restore(key)
    data = @redis.get key
    deserialize(data)
  end

  def serialize(data)
    Marshal.dump(data)
  end

  def deserialize(data)
    Marshal.load(data)
  end

  def exist_in_local?(key)
    begin
      restore(key)
    rescue StandardError
      return false
    end
    true
  end
end
