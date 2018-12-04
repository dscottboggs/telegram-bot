class MadsciTelegramBot::ShoppingListInterface::List
  property name : String
  property contents = {} of Int32 => String
  property db_id : Int32
  @deleted = false
  {% for method in {:size, :each, :map, :join} %}
  delegate {{method.id}}, to: @contents.values
  {%end%}
  def initialize(@name, @contents = {} of Int32 => String)
    @db_id = query("\
      SELECT id FROM lists \
      WHERE lists.name = #{@name};").read
    if contents = @contents
      unless contents.empty?
        update
      end
    end
  end

  def concat(other)
    @contents.concat other
    update
    @contents
  end

  def delete
    query "DELETE FROM entries WHERE list_id = #{db_id};"
    query "DELETE FROM lists WHERE id = #{db_id}"
    @deleted = true
  end

  def delete(*entries)
    query String.build do |q|
      q << "\
        DELETE FROM entries\
        WHERE list_id = #{@db_id} AND text IN ("
      entries[0..-1].each do |entry|
        q << "'#{entry}'"
      end
      q << "'#{entries[-1]}');"
    end
    update.contents
  end


  private def parse_state(query_result)
    current_rows = Hash(Int32, String).new
    query_result.each do
      key, value = query_result.read
      current_rows[key] = value
    end
    current_rows
  end
  private def db_state
    parse_state query "\
      SELECT id, text FROM entries
      WHERE list_id = #{db_id};"
  end

  # called after changes are made to the cached dataset or before returning a
  # query result, to be sure the cache isn't stale
  def update
    update db_state
  end
  # update using an already aquired ResultSet.
  private def update(query_result : DB::ResultSet)
    update(parse_state(query_result))
  end
  # update using an already aquired Hash of data.
  private def update(current_rows : Hash(Int32, String))
    if @contents.empty?
      @contents = current_rows
    else
      # merge
      exec String.build do |q|
        q << "INSERT INTO entries (id, text, list_id) VALUES "
        @contents
          .reject { |row_id, _| current_rows.has_key? row_id }
          .each do |row_id, text|
            q << "(#{row_id}, #{text}, #{db_id})"
          end
        q << ";"
      end.gsub ")(", "), ("
      # overwrite with merged state
      @contents = db_state
    end
    self
  end

  private def exec(string)
    check_deletion
    DB.open(@database_url) { |db| db.exec string }
  end
  private def query(string)
    check_deletion
    DB.open(@database_url) { |db| db.query string }
  end
  private macro check_deletion
    raise MadsciTelegramBot::ShoppingListInterface::UseAfterFree.new(@name) if @deleted
  end
end
