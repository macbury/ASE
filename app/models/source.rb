require "sitemap"
require "rss"
class Source < ActiveRecord::Base
	validates :url, :presence => true
	validates :parser, :presence => true
	
	def parse
		if sitemap?
			Sitemap.new(self.url)
		elsif rss?
			Rss.new(self.url)
		end
	end
	
	def youtube?
		parser == "youtube"
	end
	
	def sitemap?
		parser == "sitemap"
	end
	
	def rss?
		parser == "rss"
	end
end
