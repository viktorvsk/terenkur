class CreateEventTypes < ActiveRecord::Migration
  def change
    create_table :event_types do |t|
      t.string :name
      t.string :permalink
      t.timestamps
    end

    add_index :event_types, :name, unique: true
    add_index :event_types, :permalink, unique: true
  end
end
