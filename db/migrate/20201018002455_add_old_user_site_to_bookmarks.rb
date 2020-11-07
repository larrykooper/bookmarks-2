class AddOldUserSiteToBookmarks < ActiveRecord::Migration[6.0]
  def change
    change_table :bookmarks do |t|
      t.integer :old_user_site_id
    end
  end
end
