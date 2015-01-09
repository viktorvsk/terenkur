class CreateEventTypes < ActiveRecord::Migration
  def change
    create_table :event_types do |t|
      t.string :name, null: false, default: ""
      t.string :permalink, null: false, default: ""
      t.timestamps
    end

    add_index :event_types, :name, unique: true
    add_index :event_types, :permalink, unique: true
  end
end
