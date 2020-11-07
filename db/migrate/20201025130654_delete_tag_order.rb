class DeleteTagOrder < ActiveRecord::Migration[6.0]
  def change
    remove_column :bookmarks_tags, :tag_order
  end
end
