
class Tag < ApplicationRecord

  def create(name)
    @tag = Tag.new(name: name)
    @tag.save!
  end

  # return false if tag is not there, tag.id if it is there
  def name_already_in_db
    tag = Tag.where("name = '#{name}'").first
    tag ? tag.id : false
  end

  # CLASS METHODS

  def self.all_tags(order)
    sql = <<-SQL
      SELECT t.id, t.name, COUNT(*) AS count
      FROM bookmarks_tags bt
      INNER JOIN tags t
      ON bt.tag_id = t.id
      GROUP BY t.id, t.name
      ORDER BY #{order}
    SQL
    Tag.find_by_sql(sql)
  end

  def self.tags_in_rotation(order)
    sql = <<-SQL
      SELECT t.id, COUNT(*) AS count, t.name
      FROM bookmarks_tags bmt
      INNER JOIN
      bookmarks b
      ON bmt.bookmark_id = b.id
      INNER JOIN
      tags t
      ON bmt.tag_id = t.id
      WHERE b.in_rotation
      GROUP BY t.id, t.name
      ORDER BY #{order}
    SQL
    Tag.find_by_sql(sql)
  end

  def self.add_tag(tagname, bookmark_id)
    tag = Tag.new(name: tagname)
    existing = tag.name_already_in_db
    if existing
      tag_id = existing
    else
      tag.save!
      tag_id = tag.id
    end
    bt = BookmarksTag.new(bookmark_id: bookmark_id, tag_id: tag_id)
    bt.save!
  end

  def self.delete_tag(tagname, bookmark_id)
    # I don't delete the tag name from the database, even if the tag is now unused
    # Future maintenance mode?
    tag = Tag.where("name = '#{tagname}'").first
    BookmarksTag.where("bookmark_id = ? AND tag_id = ?", bookmark_id, tag.id).destroy_all
  end

  def self.save_tags(tag_string, bookmark)
    logger.info("I got to save_tags")
    tag_name_arr = tag_string.split
    tag_ids = []
    tag_name_arr.each do |tagname|
      if tagname.length > 0
        # create a new one to see if name exists, but don't save yet
        tag = Tag.new(name: tagname)
        existing = tag.name_already_in_db
        if existing
          tag_ids << existing
        else
          tag.save!
          tag_ids << tag.id
        end
      end
    end
    # Add rows in bookmarks_tags
    tag_ids.each do |tag_id|
      bt = BookmarksTag.new(bookmark_id: bookmark.id, tag_id: tag_id)
      bt.save!
    end
  end

  def self.update_tags(bookmark_id, oldtagstring, newtagstring)
    oldtags = oldtagstring.split.sort!
    newtags = newtagstring.split.sort!
    oldind = 0
    newind = 0
    max_tag = "zzzzzzzz" # 8 zs
    old_max_index = oldtags.length - 1
    new_max_index = newtags.length - 1
    done = false
    while not done

      # Are we EOF on one list or the other?
      if oldind > old_max_index
        oldtag = max_tag
      else
        oldtag = oldtags[oldind]
      end
      if newind > new_max_index
        newtag = max_tag
      else
        newtag = newtags[newind]
      end

      # Core high/low/equal logic
      if newtag < oldtag
        self.add_tag(newtag, bookmark_id)
        newind += 1
      elsif newtag > oldtag
        self.delete_tag(oldtag, bookmark_id)
        oldind += 1
      else    # equal
       newind += 1
       oldind += 1
      end

      # Are we done?
      if oldtag == max_tag && newtag == max_tag
        done = true
      end
    end
  end

  # Return true if OK, false if error condition
  def self.bulk_rename(oldname, newname)
    # Check for error - can't rename if tag not there
    old_tag = Tag.where(name: oldname)
    if old_tag.empty?
      return false
    end
    # Create a new one to see if name exists
    tag = Tag.new(name: newname)
    new_tag_id = tag.name_already_in_db
    old_tag_id = old_tag.first.id
    # If the "new" tag is already in the database, we just change bookmarks_tags
    if new_tag_id
      BookmarksTag.where(tag_id: old_tag_id).update_all(["tag_id = ?", "#{new_tag_id}"])
    else
      # New tag doesn't exist, so just rename the old
      Tag.where(name: oldname).update_all(["name = ?", "#{newname}"])
    end
    return true
  end

end
