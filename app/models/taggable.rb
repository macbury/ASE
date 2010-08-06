class Taggable < ActiveRecord::Base
	belongs_to :anime
	belongs_to :tag, :counter_cache => true
end
