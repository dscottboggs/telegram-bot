require "./shopping_list/lists_hash"

module MadsciTelegramBot::ShoppingListInterface
  include MadsciTelegramBot::Configuration
  extend self
  @@list = Hash(String, Array(String)).new
  VALID_COMMANDS = {"/need" => :add, "/list" => :get, "/have" => :delete}
  HELP_MESSAGE = <<-HERE
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
  it works just like /need.
  HERE

  def handle(message : TelegramBot::Message) : String
    if command = message.text.try &.split(' ')
      # make sure the server didn't send us a command meant for another module
      {% begin %}
      case command.shift?
      {% for command, method in VALID_COMMANDS %}
      when {{command}} then {{method.id}} command
      {% end %}
      else              "invalid command. see `/need help` for more information."
      end
      {% end %}
    else
      "ERROR: no command received (in shopping list interface)"
    end
  end

  def add(command)
    # split the remainder of the message on newlines and append those lines
    # to the list at the key represented by the first word after the command
    list_name = uninitialized String?
    case list_name = command.shift?
    when nil    then return "you must specify a list. For usage info use `/need help`"
    when "help" then return HELP_MESSAGE
    when .includes? '\n'
      list_name, first_entry = list_name.split "\n", limit: 2
      command.unshift first_entry
    end
    list = command.join(" ").split("\n").reject &.empty?
    unless @@list[list_name]?.try &.concat list
      @@list[list_name] = list
    end
    OK_RESPONSE
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
    if (list_name = command.shift?) && !list_name.empty?
      return "list #{list_name} not found" unless @@list.has_key? list_name
      if command.empty?
        @@list.delete list_name
      else
        command.join(" ").split("\n").each do |entry|
          @@list[list_name]?.try &.delete(entry)
        end
      end
      OK_RESPONSE
    else
      "you must specify a list"
    end
  end
  # {% if ENVIRONMENT == Environ::Testing %}
  # todo make inaccessible outside of testing

  # test methods
  def list=(other)
    @@list = other
  end
  def list
    @@list
  end
  # {% end %}
end
