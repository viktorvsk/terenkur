class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, default: ""
      t.boolean :admin, default: false, null: false

      # Omniauth
      t.string :provider, default: ""
      t.string :uid, default: ""

      t.timestamps
    end
  end
end
