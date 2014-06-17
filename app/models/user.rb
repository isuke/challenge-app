require_relative 'model_core'

class User < ModelCore
  TABLE_NAME = 'Users'
  EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

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
    validation

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

  private

    def validation
      Validator.new(@name) do |v|
        v.presence
        v.length_greater_than_or_equal_to(2)
        v.length_less_than_or_equal_to(6)
      end
      Validator.new(@email) do |v|
        v.format(EMAIL_FORMAT)
      end
      Validator.new(@postalcode) do |v|
        v.presence
      end
      Validator.new(@address) do |v|
        v.presence
      end
    end

end
