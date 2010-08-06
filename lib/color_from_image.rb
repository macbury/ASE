require "color"

class ColorFromImage

	attr_accessor :base_color, :link_color, :link_active_color, :link_hover_color, :red, :green, :blue, :background_color
	
	def initialize(file_name)
		command = "convert #{file_name} -scale 1x1\! -format '%[pixel:u]' info:-"
		color = %x[#{command}]
		
		if color && $?.exitstatus != 0
			raise StandardError, "There was an error determining the color!"
		end
		
		self.red, self.green, self.blue = color[/rgb\((.*)\)/, 1].split(",").collect(&:to_i)
		self.base_color = Color::RGB.new(self.red, self.green, self.blue)
		
		by_percent = 80
		
		if dark?
			self.link_color = self.base_color.lighten_by(by_percent)
			self.link_hover_color = self.base_color.lighten_by(by_percent+30)
			self.link_active_color = self.base_color.lighten_by(by_percent-10)
			self.background_color = self.base_color.lighten_by(40)
		else
			self.link_color = self.base_color.darken_by(by_percent)
			self.link_hover_color = self.base_color.darken_by(by_percent+30)
			self.link_active_color = self.base_color.darken_by(by_percent-10)
			self.background_color = self.base_color.darken_by(40)
		end
		
		
	end
	
	def light?
		self.base_color.brightness > 0.2
	end
	
	def dark?
		!light?
	end
	
	def background_color_with_alpha(alpha=0.4)
		bg = self.background_color
		"rgba(#{(bg.r * 255).round}, #{(bg.g * 255).round}, #{(bg.b * 255).round}, #{alpha})"
	end
	
end