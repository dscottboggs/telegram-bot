struct MadsciTelegramBot::ShoppingListInterface::List
  property name : String
  property contents : Set(String)
  def_equals_and_hash :name, :contents
  delegate join, to: contents

  def initialize(@name, contents : Iterable(String))
    @contents = contents.to_set
  end

  # overload to persist changes in redis
  def concat(other : Array(String))
    Configuration.redis.sadd key: name, values: other
  end

  def delete(*entries)
    delete entries.to_a
  end

  def delete(entries : Array(String))
    Configuration.redis.srem key: name, values: entries
  end
end
