require "../../spec_helper"

include MadsciTelegramBot
describe ShoppingListInterface::List do
  describe "#properties" do
    it "works" do
      clear_redis
      tv = ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: TEST_LIST_CONTENTS
      tv.name.should eq TEST_LIST_NAME
      tv.join(" ").should eq TEST_LIST_CONTENTS.join " "
      clear_redis
    end
  end
  describe "#concat" do
    it "adds an entry to a set" do
      clear_redis
      Configuration::REDIS.sadd key: TEST_LIST_NAME, values: TEST_LIST_CONTENTS[0..-2]
      tv = ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: TEST_LIST_CONTENTS[0..-2]
      tv.concat [TEST_LIST_CONTENTS[-1]]
      Configuration::REDIS.smembers(TEST_LIST_NAME).to_set.should eq TEST_LIST_CONTENTS.to_set
      clear_redis
    end
  end
  describe "#delete" do
    it "drops one element of a list" do
      clear_redis
      Configuration::REDIS.sadd key: TEST_LIST_NAME, values: TEST_LIST_CONTENTS
      tv = ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: TEST_LIST_CONTENTS
      tv.delete TEST_LIST_CONTENTS[-1]
      Configuration::REDIS.smembers(TEST_LIST_NAME).to_set.should eq TEST_LIST_CONTENTS[0..-2].to_set
      clear_redis
    end
    it "drops multiple elements of a list" do
      clear_redis
      Configuration::REDIS.sadd key: TEST_LIST_NAME, values: TEST_LIST_CONTENTS
      tv = ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: TEST_LIST_CONTENTS
      tv.delete TEST_LIST_CONTENTS[0..1]
      Configuration::REDIS.smembers(TEST_LIST_NAME).to_set.should eq TEST_LIST_CONTENTS[-2..-1].to_set
      clear_redis
    end
  end
end
