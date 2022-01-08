class CreateFlowers < ActiveRecord::Migration[6.1]
  def change
    create_table :flowers do |t|
      t.string :name, limit: 128
      t.text :description

      t.timestamps
    end

    add_index :flowers, [:name], unique: true
  end
end
