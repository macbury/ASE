class StylesheetsController < ApplicationController
	#caches_action :show, :for => 24.hours
	respond_to :css
	
	def show
		@wallpaper = YAML.load_file(File.join([Rails.root, "config/wallpaper.yml"]))
		
		stylesheet_filename = File.join([Rails.root, 'app', 'stylesheets', "#{params[:name]}.less"])
		
		if File.exists?(stylesheet_filename)
			stylesheet = render_to_string(stylesheet_filename, :layout => false)
			
			render :text => Less.parse(stylesheet), :content_type => "text/css"
		else
			render :text => ".no_file {} ", :content_type => "text/css"
		end
	end
	
end
