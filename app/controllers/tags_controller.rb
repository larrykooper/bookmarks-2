class TagsController < ApplicationController

  # This is used for autocomplete
  def index
    tag_objs = Tag.where("LOWER(name) LIKE LOWER('#{params[:q]}%')")
    @tags = tag_objs.map(&:name)
    render json: @tags
  end

end