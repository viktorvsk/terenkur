class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, null: false, default: ""
      t.string :permalink, null: false, default: ""
      t.string :header, default: ""
      t.text :description, default: ""

      t.timestamps
    end

    add_index :cities, :name, unique: true
    add_index :cities, :permalink, unique: true
  end
end
