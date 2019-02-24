require 'redis'

class Database
  def initialize
    @redis = Redis.new(host: "localhost", port: 6379, db: 01)
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
end
