class ChangeEventTypesKeywordsToText < ActiveRecord::Migration
  def change
    change_column :event_types, :keywords, :text
    remove_column :event_types, :meta_type
    drop_table :event_meta_types
  end
end
