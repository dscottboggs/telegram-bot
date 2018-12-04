require "pg"
require "./list"

class MadsciTelegramBot::ShoppingListInterface::ListsHash
  include Configuration
  @postgres_url : String = POSTGRES_URL
  @lists = Hash(String, List).new
  delegate "[]?", to: @lists
  def initialize(@postgres_url = POSTGRES_URL)
    DB.open @postgres_url do |db|
      db.query "select count(*) from lists" do |results|
        results.read
      end
    end
  rescue e : PQ::PQError
    STDERR.puts "got error #{e}, database doesn't yet exist"
    DB.connect @postgres_url[0..-10] + "postgres" do |db|
      puts "creating DB"
      db.exec "create database #{DB_NAME};"
    rescue PQ::PQError
    end
    DB.open @postgres_url do |db|
      puts "creating tables"
      db.exec "\
        CREATE TABLE IF NOT EXISTS lists (\
        id INTEGER NOT NULL PRIMARY KEY, \
        name VARCHAR(30)\
      );"
      db.exec "\
        CREATE TABLE IF NOT EXISTS entries ( \
          id INTEGER NOT NULL PRIMARY KEY, \
          text VARCHAR(140) NOT NULl, \
          list_id INT,
          FOREIGN KEY list_id REFERENCES lists(id)\
        );"
    end
  end
  def [](list_name)
    @lists[list_name]? || raise NotFound.new list_name
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
