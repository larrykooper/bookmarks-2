module BookmarksHelper

 # Creates the column headers with sorting links in the HTML
  def sortable(column, title = nil, displaying)
    title ||= column.titleize
    # Link to reverse direction if you click again
    direction = sort_direction == "asc" ? "desc" : "asc"
    if displaying == "bookmarks"
       link_to title, bookmarks_path(:sortkey => column, :direction => direction), class: "header_links"
    elsif displaying == "tag_filter"
      link_to title, bookmarks_path(:sortkey => column, :direction => direction, :tags => @tag_id), class: "header_links"
    else     # in_rotation
      link_to title, specials_showinro_path(:sortkey => column, :direction => direction), class: "header_links"
    end

  end

  def display_tag_with_link(tag)
    link_to tag.name, bookmarks_path(:tags => tag)
  end


  def display_tags(tags)
    tags.join(" ")
  end

end
