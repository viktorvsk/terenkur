class AddProfileAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sex, :integer, default: '0'
    add_column :users, :birthdate, :date
    add_column :users, :about, :text
    add_column :users, :phone, :string
  end
end
