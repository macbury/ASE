class TagsController < ApplicationController
	
	def index
		@tags = Tag.order('name ASC').all
	end
	
	def show
		@tag = Tag.find_by_permalink!(params[:id])
		@animes = @tag.animes.order("name ASC").paginate :per_page => 15, :page => params[:page]
	end
	
end
