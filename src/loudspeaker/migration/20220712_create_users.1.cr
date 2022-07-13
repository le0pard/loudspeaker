class CreateUsers < MG::Base
  def up : String
    <<-SQL
    CREATE TABLE users (
      id integer AUTO_INCREMENT NOT NULL,
      username TEXT NOT NULL,
      encrypted_password TEXT NOT NULL,
      created_at timestamp NOT NULL DEFAULT current_timestamp,
      updated_at timestamp NOT NULL DEFAULT current_timestamp
    );
    CREATE UNIQUE INDEX username_users_idx ON users (username);
    SQL
  end

  def down : String
    <<-SQL
    DROP INDEX username_users_idx;
    DROP TABLE users;
    SQL
  end
end
