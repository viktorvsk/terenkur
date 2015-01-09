class CreateEventMetaTypes < ActiveRecord::Migration
  def change
    create_table :event_meta_types do |t|
      t.string :name, null: false, default: "", index: true
      t.belongs_to :event_type, null: false

      t.timestamps
    end
  end
end
