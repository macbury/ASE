class Episode < ActiveRecord::Base
	belongs_to :anime, :counter_cache => true
	has_many :links, :dependent => :delete_all
	
	scope :empty, where("title IS NULL")
	
	def title=(new_title)
		new_title = nil if new_title =~ /episode/i
		
		if new_title && new_title.size > 255
			self.description = new_title
			
			if new_title.size > 256
				new_title = new_title[0..252] + "..."
			else
				new_title = new_title[0..255]
			end
		end
		
		write_attribute :title, new_title
	end
	
	def aired_at
		airdate || created_at
	end
end
