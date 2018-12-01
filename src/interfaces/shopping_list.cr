module MadsciTelegramBot::ShoppingListInterface
  include MadsciTelegramBot::Configuration
  extend self
  @@list = Hash(String, Array(String)).new
  VALID_COMMANDS = {"/need" => :add, "/list" => :get, "/have" => :delete}

  def handle(message : TelegramBot::Message) : String
    if command = message.text.try &.split(' ')
      # make sure the server didn't send us a command meant for another module
      {% begin %}
      case command.shift?
      {% for command, method in VALID_COMMANDS %}
      when {{command}} then {{method.id}} command
      {% end %}
      else              "invalid command"
      end
      {% end %}
    else
      "ERROR: no command received (in shopping list interface)"
    end
  end

  def add(command)
    # split the remainder of the message on newlines and append those lines
    # to the list at the key represented by the first word after the command
    case list_name = command.shift?
    when "help" then puts_help
    when nil    then "you must specify a list"
    else
      list = command.join(" ").split("\n").reject &.empty?
      unless @@list[list_name]?.try &.concat list
        @@list[list_name] = list
      end
      OK_RESPONSE
    end
  end

  def get(command)
    if list_name = command.shift?
      if list = @@list[list_name]?
        list.join("\n") + "\n" + OK_RESPONSE
      else
        "list #{list_name} not found"
      end
    else
      "you must specify a list"
    end
  end

  def delete(command)
    if (list_name = command.shift?).try { |list| !list.empty? }
      return "list #{list_name} not found" unless @@list.includes? list_name
      if command.empty?
        @@list.delete list_name
      else
        command.each do |entry|
          @@list[list_name].try &.delete(entry)
        end
      end
      OK_RESPONSE
    else
      "you must specify a list"
    end
  end

  def puts_help
    <<-HELP_MSG
      There are three commands to the shopping list module:
        - `/list [LIST_NAME]`
      Returns the contents of the list named LIST_NAME
        - `/need [LIST_NAME] [newline-separated LIST_CONTENTS]`
      Adds the contents of a list to the list named LIST_NAME. You can add one
      item simply like so:
      `/need food cookies`
       or multiple by putting a newline between them:
       ```
       /need food milk
       cookies
       ```
       or:
       ```
       /need food
       ice cream
       cheese pizza
       ```
        - `/have [LIST_NAME] [optional newline-separated LIST_CONTENTS]`
        Removes the given items from the list, returning them if there are any
        left. As a shortcut, if no LIST_CONTENTS are specified, you'll be
        asked to verify and the whole list will be deleted. Other than that,
        it works just like
    HELP_MSG
  end
  {% if Configuration::Environ.testing? %}
    # test methods
    
  {% end %}
end
