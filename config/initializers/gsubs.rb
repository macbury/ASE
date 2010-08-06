TITLE_REGEXP = []
File.open(File.join([Rails.root, "app/regexp/title_name_episode.txt"]), "r").each do |line|
	line.gsub!('\n','')
	line.gsub!('\t','')
	line.strip!
	TITLE_REGEXP << /#{line}/i
end

TITLE_GSUBS = []
File.open(File.join([Rails.root, "app/regexp/title_gsubs.txt"]), "r").each do |line|
	line.gsub!('\n','')
	line.gsub!('\t','')
	line.strip!
	TITLE_GSUBS << /#{line}/i
end

TITLE_SEASON_GSUBS = []
File.open(File.join([Rails.root, "app/regexp/title_season_gsubs.txt"]), "r").each do |line|
	line.gsub!('\n','')
	line.gsub!('\t','')
	line.strip!
	TITLE_SEASON_GSUBS << /#{line}/i
end

SKIP_URL_REGEXP = []
File.open(File.join([Rails.root, "app/regexp/skip_urls.txt"]), "r").each do |line|
	line.gsub!('\n','')
	line.gsub!('\t','')
	line.strip!
	SKIP_URL_REGEXP << /#{line}/i
end