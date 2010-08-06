require 'net/http'
require 'xml'
require 'zlib'
require 'youtube_g'

class Anime < ActiveRecord::Base
	include Paperclip
	
	validates :name, :presence => true
	
	has_many :episodes, :dependent => :destroy
	has_many :titles, :foreign_key => "anidb_id", :primary_key => "anidb_id"
	
	has_many :taggables, :dependent => :delete_all
	has_many :tags, :through => :taggables
	
	has_attached_file :poster, 
										:styles => { :thumb => "90x90#", :medium => "200x260#" },
										:url  => "/images/anime/:style/:id.:extension",
										:path => "#{Rails.root}/public/images/anime/:style/:id.:extension"
	
	scope :visible, where("episodes_count > 0")
	scope :duplicates, where("anidb_id IS NOT NULL").group("animes.anidb_id").having("count(animes.id) > 1")
	scope :latest, :order => "updated_at DESC"
	
	attr_accessor :subtitle
	before_create :create_permalink
	
	def self.create_by_title(title)
		tmp_title = Title.find_main_title(title)

		if tmp_title.nil?
			anime = Anime.find_or_create_by_name(title.capitalize.strip)
		else
			anime = Anime.find_or_initialize_by_anidb_id(tmp_title.anidb_id)

			if anime.new_record?
				anime.name = tmp_title.name
				anime.save
			end
		end
		
		return anime
	end
	
	def merge_with_anime(destination_anime)
		title = Title.find_or_initialize_by_name(self.name)
		title.anidb_id = destination_anime.anidb_id
		title.main = false
		title.save
		
		self.episodes.each do |wrong_episode|
			good_episode = Episode.find_or_initialize_by_anime_id_and_number(destination_anime.id, wrong_episode.number)
			good_episode.anime = destination_anime
			good_episode.save
			
			wrong_episode.links.all.each do |link|
				good_episode.links.find_or_create_by_url(link.url)
			end
		end
		
		destination_anime.episodes_count = destination_anime.episodes.size
		
		if destination_anime.save
			destroy
			destination_anime
		else
			false
		end
	end
	
	def permalink
		read_attribute(:permalink) || create_permalink
	end
	
	def create_permalink
		uid = self.anidb_id || self.id
		self.permalink = "#{uid}-#{PermalinkFu.escape(name)}"
	end
	
	def proposeName
		return if self.anidb_id.nil?
		tmp = Title.where("anidb_id = ?", self.anidb_id).where("main = ?", true).first
		tmp = Title.where("anidb_id = ?", self.anidb_id).first if tmp.nil?
		
		write_attribute :name, tmp.name
	end
	
	def name
		read_attribute(:subtitle) || read_attribute(:name)
	end
	
	def to_param
		permalink
	end
	
	def download_poster
		return if poster.file? || poster_url.nil?
		
		url = URI.parse("http://img7.anidb.net/pics/anime/#{poster_url}")
		store_path = File.join([Rails.root, "tmp/cache/#{poster_url}"])
		File.delete(store_path) if File.exist?(store_path)
		
		puts "Downloading poster for #{name} from #{url.to_s}"
		
		File.open(store_path, "a") do |f|
			f.write Net::HTTP.get_response(url).body
		end
		
		if File.zero?(store_path)
			
			poster_url = nil
		else
			self.poster = File.open(store_path, "r")
			
			File.delete(store_path) if save
		end
	end
	
	def getTrailer!
		return if anidb_id.nil?
		
		client = YouTubeG::Client.new
		trailers = client.videos_by(:query => "#{self.name} trailer")
		
		puts "YOUTUBE: #{self.name}"
		
		return if trailers.videos.size == 0
		
		tmp_trailer = client.video_by(trailers.videos.first.video_id)
		
		self.trailer_url = tmp_trailer.media_content.first.url
		
		puts "+ #{self.trailer_url}"
		self.save
	end
	
	def getInfoFromAniDb!
		unless anidb_id.nil?
			url = URI.parse("http://api.anidb.net:9001/httpapi?request=anime&client=animesearch&clientver=1&protover=1&aid=#{anidb_id}")
			
			empty_episodes = episodes.empty.all
			
			unless (self.description.nil? || empty_episodes.size == 0)
				puts "Skip #{name}"
				return
			end
			
			puts "Info for #{self.name} ID: #{self.anidb_id}"
			
			raw_xml = Net::HTTP.get_response(url).body
			gz = Zlib::GzipReader.new(StringIO.new(raw_xml))
			xml = XML::Document.string(gz.read)
			gz = nil
			raw_xml = nil

			self.description = xml.find_first("description").content rescue nil
			
			tmp_poster = xml.find_first("picture")
			if self.poster_url.nil? && !tmp_poster.nil?
				self.poster_url = tmp_poster.content
				self.download_poster
			end
			save
			
			xml.find("categories/category").each do |raw_xml_category|
				self.hentai ||= raw_xml_category["hentai"]
				name = raw_xml_category.find_first("name").content
				
				self.tags << Tag.find_or_create_by_name(name)	
			end
			puts "TAGS: " + self.tags.map(&:name).join(", ")
			xml.find("episodes/episode").each do |raw_xml_episode|
				ep_id = raw_xml_episode.find_first("epno").content.to_i
				empty_episodes.each do |episode|
					next if episode.number != ep_id

					puts "+ episode #{ep_id}"

					raw_xml_episode.find("title").each do |raw_titles|
						episode.title = raw_titles.content if raw_titles["lang"] == "en"
					end

					tmp_description = raw_xml_episode.find_first("description")
					episode.description ||= tmp_description.content unless tmp_description.nil?
					
					tmp_airdate = raw_xml_episode.find_first("airdate")

					unless tmp_airdate.nil?
						episode.airdate = tmp_airdate.content.to_date rescue nil
					end
					
					episode.save
				end
			end
		end
	end
	
end
