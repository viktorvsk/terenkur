class AddCurrencyToCities < ActiveRecord::Migration
  def change
    add_column :cities, :currency, :string, default: ''
  end
end
