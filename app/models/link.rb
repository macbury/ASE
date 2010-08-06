class Link < ActiveRecord::Base
	validates :url, :presence => true
	belongs_to :episode
	
	def source
		URI.parse(self.url).host.gsub('www.', '')
	end
	
	def parse
		if self.new_record? && !self.url.nil?
			doc = Nokogiri::HTML(Net::HTTP.get_response(URI.parse(self.url)).body)
			if doc.at_css("title").nil?
				logger.info "Error parsing HTML: NO <TITLE> TAG - #{url}"
				return
			end
			title = doc.at_css("title").text

			TITLE_GSUBS.each do |regexp|
				title.gsub!(regexp, '')
			end
			
			title.gsub!(/\s{2,100}/, ' ')
			title.strip!
			doc = nil
		
			TITLE_REGEXP.each do |regexp|
				if title =~ regexp
					title = $1.strip
					
					regexp_episode = $2
					season = 1

					TITLE_SEASON_GSUBS.each do |season_regexp|
						if title =~ season_regexp
							season = $1.to_i || 1
							title.gsub!(season_regexp, '')
							break
						end
					end
					
					anime = Anime.create_by_title(title)
					
					refresh_informations = anime.new_record?
					
					self.episode_id = Episode.find_or_create_by_anime_id_and_number(anime.id,regexp_episode).id
					if self.save
						logger.info "+ #{anime.name} ep. #{episode.number}: #{url}"
						refresh_informations = true
						indexed += 1
					else
						logger.info "Invalid: #{url}"
						logger.info "Title: #{title}"
						invalid += 1
					end
					
					if refresh_informations
						anime.send_later(:getInfoFromAniDb!)
						anime.send_later(:download_poster)
					end
					
					anime.send_later(:getTrailer!) if anime.trailer_url.nil?
					
					return
				end
			end
			
		else
			logger.info 'Skip ' + url
			skipped += 1
		end
		
	end
end