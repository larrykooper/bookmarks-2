class Bookmark < ApplicationRecord
  belongs_to :user
  has_many :user_visits

  def last_visit
    uv = user_visits.order("visit_timestamp DESC").first
    uv.visit_timestamp if uv
  end

  def total_visits
    user_visits.count
  end

  def tags
    sql = <<-SQL
      SELECT * FROM tags
      WHERE id IN
        (SELECT tag_id
        FROM bookmarks_tags
        WHERE "bookmark_id" = #{id})
    SQL
    Tag.find_by_sql(sql)
  end

  # Delete everything that appertains to a bookmark
  def delete(id)
    ActiveRecord::Base.transaction do
      BookmarksTag.where("bookmark_id = ?", id).destroy_all
      UserVisit.where("bookmark_id = ?", id).destroy_all
      Bookmark.destroy(id)
    end
  end

  # Class methods
  # Godawful queries

  def self.paginated_bookmarks(
    per_page,
    start,
    sort_column,
    sort_direction
  )
    offset = start
    sql = <<-SQL
      SELECT
        b.id,
        b.url,
        b.name,
        b.extended_desc,
        b.orig_posting_time,
        b.in_rotation,
        b.private,
        MAX(uv.visit_timestamp) AS last_visit,
        COUNT(uv.visit_timestamp) AS total_visits
      FROM bookmarks b
      LEFT JOIN user_visits uv
      ON uv.bookmark_id = b.id
      GROUP BY
        b.id,
        b.url,
        b.name,
        b.extended_desc,
        b.orig_posting_time
      ORDER BY #{sort_column} #{sort_direction}
      LIMIT #{per_page}
      OFFSET #{offset}
    SQL
    Bookmark.find_by_sql(sql)
  end

  # When filtering to one tag
  def self.pag_bookmarks_by_tag(
    tag_id,
    per_page,
    start,
    sort_column,
    sort_direction
    )
    offset = start
    sql = <<-SQL
    WITH bm_with_tag AS (
      SELECT bookmark_id
      FROM bookmarks_tags
      WHERE tag_id = #{tag_id}
      )
    SELECT
        b.id,
        b.url,
        b.name,
        b.extended_desc,
        b.orig_posting_time,
        b.in_rotation,
        b.private,
        MAX(uv.visit_timestamp) AS last_visit,
        COUNT(uv.visit_timestamp) AS total_visits
      FROM bookmarks b
      INNER JOIN bm_with_tag t
      ON t.bookmark_id = b.id
      LEFT JOIN user_visits uv
      ON uv.bookmark_id = b.id
      GROUP BY b.id, b.url, b.name, b.extended_desc,
          b.orig_posting_time
      ORDER BY #{sort_column} #{sort_direction}
      LIMIT #{per_page}
      OFFSET #{offset}
    SQL
    Bookmark.find_by_sql(sql)
  end

  def self.paginated_inrotation(
    per_page,
    start,
    sort_column,
    sort_direction
    )
    offset = start
    sql = <<-SQL
      SELECT
        b.id,
        b.url,
        b.name,
        b.extended_desc,
        b.orig_posting_time,
        b.in_rotation,
        b.private,
        MAX(uv.visit_timestamp) AS last_visit,
        COUNT(uv.visit_timestamp) AS total_visits
      FROM bookmarks b
      LEFT JOIN user_visits uv
      ON uv.bookmark_id = b.id
      WHERE b.in_rotation
      GROUP BY b.id, b.url, b.name, b.extended_desc,
          b.orig_posting_time
      ORDER BY #{sort_column} #{sort_direction}
      LIMIT #{per_page}
      OFFSET #{offset}
    SQL
    Bookmark.find_by_sql(sql)
  end

  def self.next_inro
    sql = <<-SQL
      SELECT url, b.id, MAX(uv.visit_timestamp) AS the_time
      FROM bookmarks b
      LEFT JOIN user_visits uv
      ON b.id = uv.bookmark_id
      WHERE in_rotation
      GROUP BY b.id
      ORDER BY the_time
    SQL
    Bookmark.find_by_sql(sql)
  end

  # Did user previously post the URL?
  # Returns the ID if yes
  def self.url_already_in_db(url)
    bookmark = Bookmark.where("url = '#{url}'").first
    bookmark ? bookmark.id : false
  end

end
