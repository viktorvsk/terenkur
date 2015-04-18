class AddAnnounceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :announce, :bool
    add_index :events, :announce
  end
end
