class CreateEventDays < ActiveRecord::Migration
  def change
    create_table :event_days do |t|
      t.belongs_to :event, index: true
      t.belongs_to :day, index: true
      t.timestamps
    end

    add_index :event_days, [:event_id, :day_id], unique: true
  end
end
