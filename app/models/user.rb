require_relative 'model_core'

class User < ModelCore
  TABLE_NAME = 'Users'

  attr_accessor :name, :email, :postalcode, :address

  def self.create_table
    ModelCore.open do |db|
      # Usersテーブルが存在しない場合は作成する。
      unless db.execute("SELECT tbl_name FROM sqlite_master WHERE type == 'table'").flatten.include?(TABLE_NAME)
        sql = <<-EOF
          CREATE TABLE #{TABLE_NAME} (
            name       string primary key,
            email      string,
            postalcode string not null,
            address    string not null
          )
        EOF

        db.execute(sql)
      end
    end
  end

  def initialize(col={})
    @name       = col["name"]
    @email      = col["email"]
    @postalcode = col["postalcode"]
    @address    = col["address"]
  end

  def save
    sql = <<-EOF
      INSERT INTO #{TABLE_NAME}
      VALUES (
        ?,?,?,?
      )
    EOF
    ModelCore.open do |db|
      db.execute(sql, @name, @email, @postalcode, @address)
    end
  end

end
