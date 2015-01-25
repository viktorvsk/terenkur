class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false, default: ""
      t.string :teaser, limit: 140, default: ""
      t.string :permalink, null: false, default: ""
      t.string :address, default: ""

      t.belongs_to :user, index: true, null: false
      t.belongs_to :event_type, index: true, null: false
      t.belongs_to :city, index: true, null: false

      t.text :content

      t.integer :min_price, default: nil
      t.integer :max_price, default: nil

      t.timestamps
    end
  end
end
