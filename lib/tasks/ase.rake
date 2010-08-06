namespace :ase do
	task :load_sources => :environment do
		raw_sources = YAML.load(File.open(File.join([Rails.root, "config/sources.yml"])))
		
		raw_sources["sitemap"].each do |name, url|
			source = Source.find_or_initialize_by_url(url)
			source.parser = "sitemap"
			source.save
		end
		
		raw_sources["youtube"].each do |url|
			source = Source.find_or_initialize_by_url(url)
			source.parser = "youtube"
			source.save
		end
		
		raw_sources["rss"].each do |name, url|
			source = Source.find_or_initialize_by_url(url)
			source.parser = "rss"
			source.save
		end
	end
	
	namespace :refresh do
		
		task :trailers => :environment do
			Anime.where("trailer_url IS NULL OR trailer_url = ?", "").all.each do |anime|
				begin
					anime.getTrailer!
				rescue Exception => e
					
				end
				
			end
		end
		
		task :background => :environment do
			br = BackgroundRotator.new
			br.rotate
		end
		
		task :episodes => :environment do
			Anime.all.each do |anime|
				anime.episodes_count = anime.episodes.count
				anime.save
			end
		end
		
		task :posters => :environment do
			Anime.all.each do |anime|
				anime.download_poster
			end
		end
		
		task :anidb => :environment do
			Title.download
		end
		
		task :titles => :environment do
			Anime.where("episodes.title IS NULL OR animes.anidb_id IS NULL").all(:joins => :episodes, :readonly => false, :select => "DISTINCT(animes.*)").each do |anime|
				title = Title.where("name ILIKE ?", "%#{anime.name}%").first

				unless title.nil?
					tmp = nil
					tmp = Title.where("anidb_id = ?", title.anidb_id).order("main DESC").first unless title.main?
					title = tmp unless tmp.nil?
				end
				
				if title.nil?
					puts "Skip #{anime.name}"
					next 
				end
				
				anime.anidb_id = title.anidb_id
				anime.name = title.name
				anime.episodes_count = anime.episodes.count
				anime.save
				
				anime.getInfoFromAniDb!
			end
		end
		
		task :tags => :environment do
			Anime.all.each do |anime|
				anime.getInfoFromAniDb!
			end
		end
		
		task :index => :environment do
			Source.all.each do |source|
				Delayed::Job.enqueue SourceRefreshJob.new(source.id), 10
			end
		end
		
		task :duplicates => :environment do
			Anime.duplicates.count(:id).each do |anidb_id, count|
				duplicated_animes = Anime.where("anidb_id = ?", anidb_id)
				puts "Merging #{duplicated_animes.first.id} with #{duplicated_animes.last.id} : #{duplicated_animes.first.name}"
				
				duplicated_animes.last.merge_with_anime(duplicated_animes.first)
			end
		end
		
		task :animes => [:index, :titles, :duplicates, :trailers]
	end
	
	namespace :clear do
		task :animes => :environment do
			Anime.delete_all
			Episode.delete_all
			Link.delete_all
		end
	end
end