require "json"

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

module MadsciTelegramBot::ShoppingListInterface
  describe MadsciTelegramBot::ShoppingListInterface do
    context "/need" do
      context "no more values" do
        it "responds with an error" do
          handle("/need").should eq "you must specify a list"
        end
      end
      context "food milk" do
        it "adds milk to the list" do
          handle("/need food milk").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          @@list["food"]?.should eq ["milk"]
          @@list.delete "food"
        end
      end
      context "food\\nmilk\\neggs" do
        it "adds milk and eggs to the list" do
          handle("/need food\nmilk\neggs").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          @@list["food"]?.should eq ["milk", "eggs"]
          @@list.delete "food"
        end
      end
    end
    context "/list" do
      context "no list specified" do
        it "responds with an error message" do
          handle("/list").should eq "you must specify a list"
        end
      end
      context "food" do
        it "responds with the contents of the list at the key \"food\" in @@list" do
          @@list["food"] = ["bread"]
          handle("/list food").should eq "bread\n#{MadsciTelegramBot::Configuration::OK_RESPONSE}"
        end
      end
    end
    context "/have" do
      context "no list specified" do
        it "responds with an error" do
          handle("/have").should eq "you must specify a list"
        end
      end
      context "food" do
        it "deletes the whole list" do
          @@list["food"] = ["bread"]
          handle("/have food").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          @@list["food"]?.should be_nil
        end
        it "deletes one element from the list" do
          @@list["food"] = ["peanut butter", "jelly"]
          handle("/have food peanut butter").should eq MadsciTelegramBot::Configuration::OK_RESPONSE
          @@list["food"].should eq ["jelly"]
        end
      end
    end
  end
end
