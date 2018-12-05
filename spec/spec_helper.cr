require "spec"
ENV["MadsciTelegramBot_testing"] = "yes"
require "../src/madsci_telegram_bot"

TEST_LIST_NAME     = "__test_list"
TEST_LIST_CONTENTS = ["one", "two", "three", "four"]

def clear_redis
  MadsciTelegramBot::Configuration.redis.del TEST_LIST_NAME
end
