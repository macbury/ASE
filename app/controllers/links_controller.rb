class LinksController < ApplicationController
	layout false
	before_filter :load_anime
	
	def show
		@link = Link.find(params[:id])
	end
	
	protected
	
		def load_anime
			@anime = Anime.find_by_permalink!(params[:anime_id])
		end
	
end
