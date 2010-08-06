require 'net/http'
require 'zlib'
require 'xml'

class Title < ActiveRecord::Base
	belongs_to :anime, :foreign_key => "anidb_id"
	
	before_save :hash!
	
	def self.hash_name(new_name)
		tmp_name = new_name.gsub(/[^0-9a-z]/i, "").strip.downcase
		tmp_name = new_name.gsub(/[\d\W_]/i, "").strip.downcase if tmp_name == ""
		
		Digest::SHA1.hexdigest(tmp_name)
	end
	
	def hash!
		self.hashed_name = Title.hash_name(self.name)
	end
	
	def self.find_by_title(title)
		Title.find_by_hashed_name(Title.hash_name(title)) || Title.where("name ILIKE ?", "%#{title}%").first
	end
	
	def self.find_main_title(title)
		tmp_title = Title.find_by_title(title)
		unless tmp_title.nil?
			tmp = nil
			tmp = Title.where("anidb_id = ?", tmp_title.anidb_id).order("main DESC").first unless tmp_title.main?
			tmp_title = tmp unless tmp.nil?
		end
		
		tmp_title
	end
	
	def self.download
		source_url = "http://anidb.net/api/animetitles.xml.gz"
		puts "Downloading: #{source_url}"
		tmp_file = File.join([Rails.root, "tmp/animetitles.xml.gz"])
		
		File.delete(tmp_file) if File.exist?(tmp_file)
		puts "Saving file in: #{tmp_file}"
	  File.open(tmp_file, "a") do |file|
	    file.write(Net::HTTP.get_response(URI.parse(source_url)).body)
	  end
		
		tmp_extracted_file = File.join([Rails.root, "tmp/animetitles.xml"])
		puts "Extracting file to: #{tmp_extracted_file}"
		File.delete(tmp_extracted_file) if File.exist?(tmp_extracted_file)
		
		File.open(tmp_extracted_file, "a") do |file|
			Zlib::GzipReader.open(tmp_file) do |gz|
				file.write(gz.read)
			end
	  end
		
		if File.zero?(tmp_extracted_file)
			puts "FILE IS EMPTY!!!! WHAT THE FUCK???"
			return
		else
			Title.parse(tmp_extracted_file)
		end
	end
	
	def self.parse(file_name)
		reader = XML::Reader.file(file_name)
		animdb_id = nil
		puts "Parsing file #{file_name}"
		while reader.read
			if reader.name == "anime" && reader.node_type == XML::Reader::TYPE_ELEMENT
				while(reader.read_attribute_value == 0)
					reader.move_to_next_attribute
				end
				
				animdb_id = reader.value
				
				while (!(reader.name == "anime" && reader.node_type == XML::Reader::TYPE_END_ELEMENT))
					reader.read
					
					isMainTitle = false
					
					if reader.name == "title" && reader.node_type == XML::Reader::TYPE_ELEMENT
						isMainTitle = (reader["type"] == "main")
						reader.read
						
						if reader.node_type == XML::Reader::TYPE_TEXT
							title = Title.find_or_initialize_by_name_and_anidb_id(reader.value, animdb_id)
							title.main = isMainTitle unless title.main?
							title.save
							puts "#{title.main ? "M" : "+"} #{animdb_id}: #{reader.value}"
						end
					end
				end
				
				animdb_id = nil
			end
		end
	end
	
	def main?
		main
	end
	
end
