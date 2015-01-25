class AddMinPriceAndMaxPriceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :min_price, :integer, default: nil
    add_column :events, :max_price, :integer, default: nil
  end
end
