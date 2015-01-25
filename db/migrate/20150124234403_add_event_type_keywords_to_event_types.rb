class AddEventTypeKeywordsToEventTypes < ActiveRecord::Migration
  def change
    add_column :event_types, :keywords, :text
    add_index :event_types, :keywords
  end

end
