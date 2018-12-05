require "json"
require "../spec_helper"

def new_message(text)
  JSON::PullParser.new({
    message_id: rand(0..Int32::MAX),
    date:       Time.now.to_unix,
    chat:       {
      id:    MadsciTelegramBot::Configuration::TEST_CHAT_ID,
      type:  "group",
      title: "bot stuff",
    },
    text: text,
  }.to_json)
end

def handle(command_text)
  MadsciTelegramBot::ShoppingListInterface.handle(
    TelegramBot::Message.new(new_message text: command_text))
end

module MadsciTelegramBot::ShoppingListInterfaceSpec
  describe MadsciTelegramBot::ShoppingListInterface do
    context "/need" do
      context "no more values" do
        it "responds with an error" do
          handle("/need").should eq "you must specify a list. For usage info use `/need help`"
        end
      end
      context "#{TEST_LIST_NAME} #{TEST_LIST_CONTENTS[0]}" do
        it "adds #{TEST_LIST_CONTENTS[0]} to the list" do
          clear_redis
          handle("/need #{TEST_LIST_NAME} #{TEST_LIST_CONTENTS[0]}").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          MadsciTelegramBot::ShoppingListInterface.list[TEST_LIST_NAME]?.should eq MadsciTelegramBot::ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: [TEST_LIST_CONTENTS[0]]
          MadsciTelegramBot::ShoppingListInterface.list.delete TEST_LIST_NAME
          clear_redis
        end
      end
      context "#{TEST_LIST_NAME}\\n#{TEST_LIST_CONTENTS[0]}\\n#{TEST_LIST_CONTENTS[1]}" do
        it "adds #{TEST_LIST_CONTENTS[0]} and #{TEST_LIST_CONTENTS[1]} to the list" do
          clear_redis
          handle("/need #{TEST_LIST_NAME}\n#{TEST_LIST_CONTENTS[0]}\n#{TEST_LIST_CONTENTS[1]}").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          MadsciTelegramBot::ShoppingListInterface
            .list[TEST_LIST_NAME]?
            .should eq MadsciTelegramBot::ShoppingListInterface::List.new(
            name: TEST_LIST_NAME,
            contents: TEST_LIST_CONTENTS[0..1])
          MadsciTelegramBot::ShoppingListInterface.list.delete TEST_LIST_NAME
          clear_redis
        end
      end
    end
    context "/list" do
      context "no list specified" do
        it "responds with an error message" do
          handle("/list").should eq "you must specify a list. See `/need help` for usage information."
        end
      end
      context TEST_LIST_NAME do
        it "responds with the contents of the list at the key \"#{TEST_LIST_NAME}\" in list" do
          clear_redis
          MadsciTelegramBot::ShoppingListInterface.list[TEST_LIST_NAME] = ["bread"]
          handle("/list #{TEST_LIST_NAME}").should eq "bread\n#{MadsciTelegramBot::Configuration::OK_RESPONSE}"
          clear_redis
        end
      end
    end
    context "/have" do
      context "no list specified" do
        it "responds with an error" do
          handle("/have").should eq "you must specify a list. See `/need help` for usage information."
        end
      end
      context TEST_LIST_NAME do
        it "deletes the whole list" do
          clear_redis
          MadsciTelegramBot::ShoppingListInterface.list[TEST_LIST_NAME] = ["bread"]
          handle("/have #{TEST_LIST_NAME}").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          MadsciTelegramBot::ShoppingListInterface.list[TEST_LIST_NAME]?.should be_nil
          clear_redis
        end
        it "deletes one element from the list" do
          clear_redis
          MadsciTelegramBot::ShoppingListInterface.list[TEST_LIST_NAME] = ["peanut butter", "jelly"]
          handle("/have #{TEST_LIST_NAME} peanut butter").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          MadsciTelegramBot::ShoppingListInterface
            .list[TEST_LIST_NAME]?
            .should eq MadsciTelegramBot::ShoppingListInterface::List.new name: TEST_LIST_NAME, contents: ["jelly"]
          clear_redis
        end
      end
    end
  end
end
