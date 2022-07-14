require "mg"
require "sqlite3"
require "./migration/*"

module Loudspeaker
  class Database
    Log = ::Log.for(self)

    getter db_path : String
    getter db : DB::Database

    def initialize(db_path : String)
      @db_path = db_path
      @db = open
      migrate
    end

    def open
      DB.open "sqlite3:#{@db_path}"
    end

    def close
      @db.close
    end

    def reconnect
      close
      @db = open
    end

    private def migrate
      mg = MG::Migration.new @db
      mg.migrate
    end
  end
end
