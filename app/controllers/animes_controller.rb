class AnimesController < ApplicationController
	
	before_filter :authenticate, :only => [:merge, :invalid, :destroy]
	before_filter :prepare_query, :only => [:index, :latest] 
	
	def latest
		@animes = @query.latest.paginate :per_page => 15, :page => params[:page]
		render(:index)
	end
	
	def index
		@animes = @query.paginate :per_page => 15, :page => params[:page]
	end
	
	def invalid
		@animes = Anime.where("anidb_id IS NULL").order("created_at DESC").all

	end
	
	def show
		@anime = Anime.find_by_permalink!(params[:id])
		@episodes = @anime.episodes.order('number DESC').all(:include => :links)
		@titles = @anime.titles.order('main DESC, name ASC').all
	end
	
	def merge
		@anime = Anime.find_by_permalink!(params[:id])
		if params[:anidb_id]
			Title.find_by_anidb_id!(params[:anidb_id])

			@destination_anime = Anime.find_or_initialize_by_anidb_id(params[:anidb_id])

			if @destination_anime.new_record?
				@destination_anime.proposeName
				@destination_anime.save
			end
		else
			@destination_anime = Anime.find_by_permalink!(params[:anime_id])
		end
		
		@destination_anime = @anime.merge_with_anime(@destination_anime)
		
		if @destination_anime
			@anime.destroy
			redirect_to @destination_anime
		else
			logger.debug @destination_anime.errors.full_messages.join(", ")
			redirect_to invalid_animes_path
		end
		
	end
	
	def destroy
		@anime = Anime.find_by_permalink!(params[:id])
		@anime.destroy
		
		redirect_to invalid_animes_path
	end
	
	protected
		
		def prepare_query
			@query = Anime.visible
			if params[:letter]
				if params[:letter] == "0"
					@query = @query.where("name !~* '^[a-z]'") # thank god for postgresql regexp
				else
					@query = @query.where("name ILIKE ?", "#{params[:letter]}%") 
				end
			end
			@query = @query.order("name ASC")
		end
end
