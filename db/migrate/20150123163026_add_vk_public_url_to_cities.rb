class AddVkPublicUrlToCities < ActiveRecord::Migration
  def change
    add_column :cities, :vk_public_url, :string
  end
end
