class MadsciTelegramBot::ShoppingListInterface::NotFound < MadsciTelegramBot::ShoppingListInterface::Exception
  def initialize(name)
    super "#{name} was not found"
  end
end
