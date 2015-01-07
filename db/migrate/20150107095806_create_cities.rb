class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :permalink
      t.string :header
      t.string :permalink
      t.text :description

      t.timestamps
    end

    add_index :cities, :name, unique: true
    add_index :cities, :permalink, unique: true
  end
end
