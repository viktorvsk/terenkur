class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.string :name, null: false, default: ""

      t.timestamps
    end

    add_index :days, :name, unique: true
  end
end
