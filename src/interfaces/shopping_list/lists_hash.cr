class MadsciTelegramBot::ShoppingListInterface::ListsHash
  @lists = Hash(String, List).new
  delegaete "[]?", to: @lists
  def [](list_name)
    @lists[list_name]? || raise "list #{list_name} not found"
  end
  def []=(list_name, contents : Array(String))
    delete list_name
    @lists[list_name] = List.new name: list_name, contents: contents
  end
  def delete(list_name)
    @lists[list_name]?.try &.delete
    @lists.delete list_name
  end
end
