# TODO: Write documentation for `MadsciTelegramBot`
require "telegram_bot"
require "./webhook_bot"
require "./config"
require "./interfaces/shopping_list"

module MadsciTelegramBot
  VERSION = "0.1.0"

  INTERFACES = {"/weather" => WeatherInterface, "/ping" => PingInterface}

  class Bot < WebhookBot
    def handle(message : TelegramBot::Message)
      case (chat = message.chat).id
      when Configuration::TEST_CHAT_ID
        case
        when text = message.text
          {% begin %}
          case text
          {% for command in ShoppingListInterface::VALID_COMMANDS %}
          when .starts_with? {{command}} then send_message chat_id: chat.id, text: ShoppingListInterface.handle message{% end %}
          when nil     then reply message, "no command received"
          when "/ping" then reply message, "pong"
          when "/weather" then send_message( chat_id: chat.id, text: "not yet implemented.")
          else
            log.warn "received unknown command #{text}"
          end
          {% end %}
        else
          log.info "got null message from #{message}"
        end
      else
        log.warn "received message #{message} from unknown chat #{chat}"
      end
    end
  end
end

MadsciTelegramBot::Bot.new.serve_up unless MadsciTelegramBot::Environ.testing?
