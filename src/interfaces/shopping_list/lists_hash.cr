require "./list"

class MadsciTelegramBot::ShoppingListInterface::ListsHash
  include Configuration
  def [](list_name)
    self[list_name]? || raise NotFound.new "list_name"
  end

  def []?(list_name)
    # debugger
    redis_results = REDIS.smembers list_name
    List.new list_name, contents: redis_results.map &.as(String) unless redis_results.empty?
  end

  def []=(list_name, contents : Array(String))
    delete list_name
    if (redis_results = REDIS.sadd list_name, contents) != contents.size
      <<-HERE
        wrong number of results returned from redis:
        #{redis_results.inspect} vs expected #{contents.size.inspect}.
      HERE
    else
      List.new list_name, contents
    end
  end

  def has_key?(key)
    REDIS.exists(key) === 1
  end

  def has_keys?(*keys)
    REDIS.exists(*keys) === keys.size
  end

  def delete(list_name)
    REDIS.del list_name
  end
end
