class AddProfileAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sex, :integer
    add_column :users, :birthdate, :date
    add_column :users, :about, :text
  end
end
