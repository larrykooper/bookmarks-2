class BookmarksController < ApplicationController
  before_action :authenticate_user!

  # The reason I excluded update from protect_from_forgery
  #  is that Rails thought the "save new" of fix a posting was a create,
  #  not an update, so the tokens did not match
  # There probably is another way to fix that if I want to
  protect_from_forgery except: :update

  # helper_method makes controller methods available to the view
  helper_method :sort_column, :sort_direction
  # conventional order of actions
  # index, show, new, edit, create, update, destroy

  def index
    @per_page = 100
    @sortkey = sort_column
    @direction = sort_direction
    @start = params[:start] || 0
    if params[:tags]  # filtered by tag
      @tag_id = params[:tags]
      @bookmarks = Bookmark.pag_bookmarks_by_tag(@tag_id, @per_page, @start, @sortkey, @direction)
      @total_rows = BookmarksTag.where("tag_id = #{@tag_id}").count
      @displaying = "tag_filter"
      tag_name = Tag.find(@tag_id).name
      @message = "Tag: #{tag_name} "
    else  # everything
      @bookmarks = Bookmark.paginated_bookmarks(@per_page, @start, @sortkey, @direction)
      @total_rows = Bookmark.count
      @displaying = "bookmarks"
      @message = "Welcome, stormville."
    end
    @tags = Tag.all_tags("LOWER(name)")
  end

  def show
    @bookmark = Bookmark.find(params[:id])
    @user_visit = UserVisit.new(user_id: 1, visit_timestamp: Time.now, bookmark_id: params[:id])
    @user_visit.save
    redirect_to @bookmark.url
  end

  def new
    @bookmark = Bookmark.new
    # Populate fields if bookmarklet has been used
    if params[:url]
      @bookmark.url  = params[:url]
    end

    if params[:name]
      @bookmark.name  = params[:name]
    end

  end

  def edit
    @bookmark = Bookmark.find(params[:id])
    @tag_names = @bookmark.tags.map(&:name)
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    existing = Bookmark.url_already_in_db(@bookmark.url)
    if !existing
      tags = params[:tags]
      @bookmark.user_id = current_user.id
      @bookmark.orig_posting_time = Time.now
      if @bookmark.valid?
        ActiveRecord::Base.transaction do
          @bookmark.save!
          Tag.save_tags(tags, @bookmark)
        end
        redirect_to bookmarks_path
      else
        render 'new'
      end
    else   # User has posted same bookmark before; go into "fix a post" mode
      @previous_post = Bookmark.find(existing)
      @previous_tag_names = @previous_post.tags.map(&:name)
      @new_tag_names = params[:tags].split
      render "fix_a_posting"
    end
  end

  def update
    @bookmark = Bookmark.find(params[:id])
    if params[:save_it] == "save" || params[:save_previous] == "save previous" || params[:save_new] == "save new"
      ActiveRecord::Base.transaction do
        response = @bookmark.update(bookmark_params) # true if update successful, otherwise false
        Tag.update_tags(@bookmark.id, params[:oldtagstring], params[:tags])
      end
      if response
        redirect_to bookmarks_path, notice: 'Bookmark was successfully updated.'
      else
        render :edit
      end
    else   # delete
      @bookmark.delete(@bookmark.id)
      redirect_to bookmarks_path, notice: 'Bookmark was successfully deleted.'
    end
  end

  private
    def bookmark_params
      params.require(:bookmark).permit(:url, :name, :extended_desc, :orig_posting_time, :in_rotation, :private, :tags)
    end

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
