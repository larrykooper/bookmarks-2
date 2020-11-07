class SpecialsController < ApplicationController
  before_action :authenticate_user!
  helper_method :sort_column, :sort_direction

  def vnsinro
    logger.info("vnsinro")
    @bookmark = Bookmark.next_inro.first
    @user_visit = UserVisit.new(user_id: 1, visit_timestamp: Time.now, bookmark_id: @bookmark.id)
    @user_visit.save
    redirect_to @bookmark.url
  end

  def showinro
    @per_page = 100
    @sortkey = sort_column
    @direction = sort_direction
    @start = params[:start] || 0
    @bookmarks = Bookmark.paginated_inrotation(@per_page, @start, @sortkey, @direction)
    @total_rows = Bookmark.where("in_rotation").count
    @tags = Tag.tags_in_rotation("LOWER(t.name)")
    @message = "You are now viewing your in-rotation bookmarks."
    @displaying = "in_rotation"
    render 'bookmarks/index'
  end

  def random
    @bookmark = Bookmark.order("RANDOM()").first
    @message = "Random Bookmark"
  end

  # This action handles the ajax call to re-sort the tags
  def refreshtags
    sort = params[:settagsort]
    page_from = params[:page]
    order = sort == 'alpha' ? "LOWER(t.name)" : "count DESC"
    if page_from == "bookmarks"
      @tags = Tag.all_tags(order)
    else
      @tags = Tag.tags_in_rotation(order)
    end
    render json: @tags
  end

  private

    def sort_column
      if !params[:sortkey]
        :orig_posting_time
      else
        params[:sortkey].to_sym
      end
    end

    # Default sort direction is descending
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

end
