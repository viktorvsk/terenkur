class CreateEventDays < ActiveRecord::Migration
  def change
    create_table :event_days do |t|
      t.belongs_to :event, index: true, null: false
      t.belongs_to :day, index: true, null: false
      t.timestamps
    end

    add_index :event_days, [:event_id, :day_id], unique: true
  end
end
