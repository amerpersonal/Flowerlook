class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :username, limit: 32
      t.string :password_digest, limit: 128
      t.string :email, limit: 64

      t.timestamps
    end

    add_index :users, [:username], unique: true
    add_index :users, [:email], unique: true
  end
end
