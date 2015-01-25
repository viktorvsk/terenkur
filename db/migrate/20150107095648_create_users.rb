class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false, default: ""
      t.boolean :admin, default: false, null: false
      t.string :authentication_token

      # Profile
      t.integer :sex, default: 0
      t.date :birthdate
      t.text :about
      t.string :phone

      # Omniauth
      t.string :provider, default: ""
      t.string :uid, default: ""

      t.timestamps
    end
    add_index :users, :authentication_token, unique: true
  end
end
