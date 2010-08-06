require 'xml'
require 'net/http'
require 'open-uri'

class Rss
	
	def initialize(source_url)
		puts "====================================="
		puts "Downloading: #{source_url}"
		
		raw_rss = Net::HTTP.get_response(URI.parse(source_url)).body
		
		if raw_rss == nil || raw_rss == ""
			puts "ERROR: EMPTY RESPONSE"
			return
		end
		
		xml = XML::Document.string(raw_rss)
		indexed = 0
		skipped = 0
		invalid = 0
		
		xml.find("channel/item").each do |item|
			link = Link.find_or_initialize_by_url(item.find_first("link").content)
			title = item.find_first("title").content
			if link.new_record? && !link.url.nil? && !title.nil? && title != "" 
				TITLE_GSUBS.each do |regexp|
					title.gsub!(regexp, '')
				end
				
				title.gsub!(/\s{2,100}/, ' ')
				title.strip!
				
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

						link.episode_id = Episode.find_or_create_by_anime_id_and_number(anime.id,regexp_episode).id
						
						if link.save
							puts "+ #{anime.name} ep. #{link.episode.number}: #{link.url}"
							indexed += 1
						else
							puts "Invalid: #{link.url}"
							puts "Title: #{title}"
							invalid += 1
						end
						break
					end
				end
				
			else
				puts "Skip: [#{title}] #{link.url}"
				skipped += 1
			end
		end
		
		puts "\n\n\n\n\n\n"
		puts "==========================================================="
		puts "INDEXED = #{indexed}"
		puts "SKIPPED = #{skipped}"
		puts "INVALID = #{invalid}"
		puts "==========================================================="
	end
	
end