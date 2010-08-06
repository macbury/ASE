require 'xml'
require 'net/http'
require 'nokogiri'
require 'open-uri'

class Sitemap
	def initialize(source_url)
		logfile = File.open(File.join([Rails.root, "log", "sitemap_parser.log"]), 'a')
		logfile.sync = true
		logger = Logger.new(logfile)
		logger.info "====================================================="
		logger.info "Downloading: #{source_url}"
		logger.info "====================================================="
		
		tmp_file = File.join([Rails.root, "tmp/cache_sitemap.xml"])

		if source_url =~ /\.gz$/i
			gz_tmp_file = File.join([Rails.root, "tmp/cache_sitemap.xml.gz"])
			
			File.delete(gz_tmp_file) if File.exist?(gz_tmp_file)
			File.open(gz_tmp_file, "a") do |file|
		    file.write(Net::HTTP.get_response(URI.parse(source_url)).body)
		  end
			
			logger.info "Decompresing file: #{tmp_file}"
			logger.info "====================================================="
			File.delete(tmp_file) if File.exist?(tmp_file)
			File.open(tmp_file, "a") do |file|
				Zlib::GzipReader.open(gz_tmp_file) do |gz|
					file.write(gz.read)
				end
		  end
		else
			File.delete(tmp_file) if File.exist?(tmp_file)
		  File.open(tmp_file, "w") do |file|
		    file.write(Net::HTTP.get_response(URI.parse(source_url)).body)
		  end
			logger.info "Caching file in: #{tmp_file}"
			logger.info "====================================================="
		end

		return if File.zero?(tmp_file)
		logger.info "Parsing file..."
		logger.info "====================================================="
		
		reader = XML::Reader.file(tmp_file)
		indexed = 0
		skipped = 0
		invalid = 0
		
		begin
			while reader.read
				if reader.name == "loc" && reader.node_type == XML::Reader::TYPE_ELEMENT
					reader.read
					
					skip_this_url = false
					
					SKIP_URL_REGEXP.each do |skip_regexp|
						if reader.value =~ skip_regexp
							skip_this_url = true
							break
						end
					end
					
					unless skip_this_url
						link = Link.find_or_initialize_by_url(reader.value)
						logger.info "Adding to quee #{reader.value}"
						link.send_later(:parse) if link.new_record? && !link.url.nil?
					else
						logger.info "Skipping #{reader.value}"
					end

				end
			end
		rescue Exception => e
			logger.info "Error: #{e.to_s}"
		end
		
		logger.info "\n\n\n\n\n\n"
		logger.info "==========================================================="
		logger.info "INDEXED = #{indexed}"
		logger.info "SKIPPED = #{skipped}"
		logger.info "INVALID = #{invalid}"
		logger.info "==========================================================="
	end

	
end