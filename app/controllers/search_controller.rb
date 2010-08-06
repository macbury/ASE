class SearchController < ApplicationController
	
	def show
		@title = Title.find_by_title(params[:query]).anidb_id rescue 0
		@animes = Anime.visible.where("animes.anidb_id = ? OR animes.name ILIKE ? OR titles.name ILIKE ?", @title, "%#{params[:query]}%", "%#{params[:query]}%").order("updated_at DESC").paginate(
				:joins => [:titles], 
				:per_page => 15,
				:page => params[:page],
				:select => "DISTINCT (animes.*)")
		
		
		redirect_to @animes.first if @animes.size == 1
	end
	
end
