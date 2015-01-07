class CreateEventDescriptions < ActiveRecord::Migration
  def change
    create_table :event_descriptions do |t|
      t.text :content
      t.belongs_to :event

      t.timestamps
    end

    add_index :event_descriptions, :event_id, unique: true
  end
end
