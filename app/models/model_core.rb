require 'sqlite3'
include SQLite3

require_relative 'validator'

class ModelCore
  DB_PATH  = 'db/production.db'

  def self.open
    Database.new(DB_PATH) do |db|
      yield db
    end
  end
end
