class Tag < ActiveRecord::Base
	has_many :taggables, :dependent => :delete_all
	has_many :animes, :through => :taggables
	
	before_create :create_permalink
	
	def create_permalink
		self.permalink = PermalinkFu.escape(name)
	end
	
	def to_param
		self.permalink
	end
end
