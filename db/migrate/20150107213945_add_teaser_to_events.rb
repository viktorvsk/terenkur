class AddTeaserToEvents < ActiveRecord::Migration
  def change
    add_column :events, :teaser, :string, limit: 140
  end
end
