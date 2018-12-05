class MadsciTelegramBot::ShoppingListInterface::NotFound < MadsciTelegramBot::ShoppingListInterface::Exception
  def initialize(name)
    super "list named #{name} not found"
  end
end
