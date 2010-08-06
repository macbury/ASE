module AnimesHelper
	
	def description(text)
		return if text.nil?
		text.gsub!(/\A^\*.+$/i, '')
		text.gsub!(/(http:\/\/anidb\.net\/[a-zA-Z0-9]+)\s\[([a-zA-Z0-9\s\/`\-"]+)\]/i, link_to('\2','\1', :target => "_blank"))
		text.html_safe
	end
	
	def aired_ago(date)
		if date.to_datetime >= 7.days.ago.at_beginning_of_day
			content_tag :span, distance_of_time_in_words_to_now(date) + " " + t('datetime.distance_in_words.ago'), :title => l(date, :format => :long)
		else
			content_tag :span, l(date, :format => "%d %b %Y"), :title => distance_of_time_in_words_to_now(date) + " " + t('datetime.distance_in_words.ago')
		end
	end
	
end
