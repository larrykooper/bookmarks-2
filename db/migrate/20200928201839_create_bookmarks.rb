class CreateBookmarks < ActiveRecord::Migration[6.0]
  def change
    create_table :bookmarks do |t|
      t.string :url
      t.integer :user_id
      t.string :name
      t.text :extended_desc
      t.timestamp :orig_posting_time
      t.boolean :in_rotation
      t.boolean :private

      t.timestamps
    end
  end
end
