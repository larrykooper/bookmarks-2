class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :password
      t.string :email
      t.string :full_name
      t.string :nick

      t.timestamps
    end
  end
end
