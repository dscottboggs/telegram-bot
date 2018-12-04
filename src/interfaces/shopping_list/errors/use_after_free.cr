class MadsciTelegramBot::ShoppingListInterface::UseAfterFree < MadsciTelegramBot::ShoppingListInterface::Exception
  def initialize(list_name)
    super "\
      use of ShoppingListInterface::List #{list_name} after it was deleted \
      from the database!"
  end
end
