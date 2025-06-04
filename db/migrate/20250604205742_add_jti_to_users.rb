# db/migrate/YYYYMMDDHHMMSS_add_jti_to_users.rb
class AddJtiToUsers < ActiveRecord::Migration[7.1] # Ou a versão do Rails que você está usando, ex: 7.1
  def change
    add_column :users, :jti, :string, null: false
    add_index :users, :jti, unique: true
  end
end