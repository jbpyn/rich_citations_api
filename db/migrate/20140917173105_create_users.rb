class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     'api_key', limit:36, null:false
      t.string     'full_name'
      t.string     'email'

      t.timestamps null:false
    end

    add_index :users, :api_key, unique:true
  end
end
