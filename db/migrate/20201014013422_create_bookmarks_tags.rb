class CreateBookmarksTags < ActiveRecord::Migration[6.0]
  def change
    create_table :bookmarks_tags do |t|
      t.references :bookmark, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.integer :tag_order

      t.timestamps
    end
  end
end
