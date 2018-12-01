require "json"

module MadsciTelegramBot
  class WebhookBot < TelegramBot::Bot
    protected getter log : Logger = Logger.new STDOUT
    @webhook_info : WebhookInfo?

    def initialize
      super name: "Notifier", token: Configuration.api_token, allowed_updates: ["messages"]

      @log.level = Configuration::LOG_LEVEL
    end

    def serve_up(ip = Configuration::IP_ADDR, port = Configuration::PORT)
      check_webhook && serve ip, port
    end

    def check_webhook
      return true if webhook_info.url === Configuration.webhook_url
      unless webhook_info.url.empty?
        delete_webhook || raise "failed to delete webhook: #{webhook_info}"
      end
      set_webhook Configuration.webhook_url
    end

    def webhook_info : WebhookInfo
      if (info = @webhook_info)
        return info
      elsif result = request "getWebhookInfo"
        @webhook_info ||= WebhookInfo.from_json result.to_json
        # HACK: string -> JSON::Any -> String -> WebhookInfo
      else
        raise "failed to delete webhook"
      end
    end
  end

  struct WebhookInfo
    include JSON::Serializable
    property url : String
    property has_custom_interface : Bool?
    property pending_update_count : Int64
    property last_error_date : Int64?
    property last_error_message : String?
    property max_connections : Int64?
    property allowed_updates = [] of String?
  end
end
