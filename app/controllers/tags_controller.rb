class TagsController < ApplicationController

  def index
    tag_objs = Tag.where("name LIKE '#{params[:term]}%'")
    @tags = tag_objs.map(&:name)
    render json: @tags
  end

end