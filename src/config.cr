module MadsciTelegramBot
  module Configuration
    @@secret : String?
    @@api_token : String?
    IP_ADDR   = "0.0.0.0"
    PORT      = 80
    LOG_LEVEL = if Environ.production?
                  Logger::WARN
                else
                  Logger::DEBUG
                end
    TEST_CHAT_ID = 431418362
    SECRET_FILE  = "SECRET"
    OK_RESPONSE  = "\u{1F44D}\u{1F44C}"
    ENVIRONMENT = Environ.current

    POSTGRES_URL = File.read("POSTGRES_URL").chomp
    DB_NAME = "ms_tg_bot"

    def self.api_token
      @@api_token ||= File.read("API_TOKEN").strip
    end

    def self.webhook_url
      "https://telegram-bot.madscientists.co/#{secret}"
    end

    def self.secret
      @@secret ||= if File.readable? SECRET_FILE
                     File.read SECRET_FILE
                   else
                     _secret = generate_secret
                     File.write filename: SECRET_FILE, content: _secret
                     _secret
                   end
    end

    def self.generate_secret
      secret_bytes = Slice(UInt8).new size: 64, value: 0
      64.times do |idx|
        # get 512 bits (64 bytes) of entropy
        secret_bytes[idx] = Random::Secure.next_u
      end
      Base64.urlsafe_encode secret_bytes
    end
  end

  enum Environ
    Development
    Testing
    Production

    def self.current
      if ENV["MadsciTelegramBot_testing"]?
        Testing
      else
        Development
      end
    end

    def current
      self.current
    end

    def self.development?
      current === Development
    end

    def self.production?
      current === Production
    end

    def self.testing?
      current === Testing
    end
  end
end
