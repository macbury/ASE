require 'net/http'
require 'open-uri'
require 'nokogiri'

class BackgroundRotator
	
	def rotate
		gallery_url = "http://www.theotaku.com/wallpapers/?sort_by=featured&resolution=1280_800&date_filter=48_hours"
		doc = Nokogiri::HTML(Net::HTTP.get_response(URI.parse(gallery_url)).body)
		
		wallpapers = doc.css('#content .thumb').css('span a')
		
		random_image_path = wallpapers[(rand*wallpapers.size).round][:href]
		puts "Wallpaper url: #{random_image_path}"
		
		doc = Nokogiri::HTML(Net::HTTP.get_response(URI.parse(random_image_path)).body)
		image_page_path = doc.css('#mainContent .frame a').first[:href]
		puts "Wallpaper image page url: #{image_page_path}"
		
		html = Net::HTTP.get_response(URI.parse(image_page_path)).body
		html.gsub!('<div id="wall_holder" />', '<div id="wall_holder">')
		doc = Nokogiri::HTML(html)
		
		image_path = doc.at_css('#wall_holder img')[:src]
		puts "Wallpaper image url: #{image_path}"
		
		new_wallpaper_path = File.join([Rails.root, "tmp/cache/temp.jpg"])
		puts "Saving file in cache: #{new_wallpaper_path}"
		
		File.delete(new_wallpaper_path) if File.exists?(new_wallpaper_path)
		File.open(new_wallpaper_path, "a") do |file|
	    file.write(Net::HTTP.get_response(URI.parse(image_path)).body)
	  end

		return if File.zero?(new_wallpaper_path)
		
		public_wallpaper_path = File.join([Rails.root, "public/images/wallpaper.jpg"])
		puts "Scaling file to: #{public_wallpaper_path}"
		
		command = "convert #{new_wallpaper_path} -resize 1280x800 -quality 75 #{public_wallpaper_path}"
		%x[#{command}]

		if $?.exitstatus != 0
			puts "Could not change background!"
			return
		end
		
		store_config(random_image_path, public_wallpaper_path)
	end	
	
	def store_config(wallpaper_url, wallpaper_path)
		css = ColorFromImage.new(wallpaper_path)
		config = {
			:wallpaper_url => wallpaper_url,
			:base_color => css.base_color.html,
			:background_color => css.background_color_with_alpha,
			:link_color => css.link_color.html,
			:link_hover_color => css.link_hover_color.html,
			:link_active_color => css.link_active_color.html
		}
		
		config_path = File.join(Rails.root, "config/wallpaper.yml")
		File.delete(config_path) if File.exists?(config_path)
		
		File.open(config_path, "a") do |file|
	    file.write(YAML::dump(config))
	  end
	
		puts YAML::dump(config)
	end
	
end