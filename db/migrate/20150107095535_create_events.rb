class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.belongs_to :user, index: true
      t.belongs_to :event_type, index: true
      t.belongs_to :city, index: true
      t.belongs_to :event_type, index: true

      t.timestamps
    end
  end
end
