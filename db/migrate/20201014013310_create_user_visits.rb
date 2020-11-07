class CreateUserVisits < ActiveRecord::Migration[6.0]
  def change
    create_table :user_visits do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamp :visit_timestamp
      t.references :bookmark, null: false, foreign_key: true

      t.timestamps
    end
  end
end
