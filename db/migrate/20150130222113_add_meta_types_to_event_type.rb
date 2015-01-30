class AddMetaTypesToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :meta_type, :text
  end
end
