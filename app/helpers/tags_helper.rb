module TagsHelper
	
	def tag_cloud_for_tags(tags,classes=%w( tag1 tag2 tag3 tag4, tag5, tag6, tag7, tag8, tag9, tag10, tag11, tag12 ))
    max, min = 0, 0
    
    tags.each do |tag|
      max = [tag.taggables_count, max].max
      min = [tag.taggables_count, min].min
    end
    
    div = ((max - min) / classes.size) + 1
    
    tags.each do |tag|
      yield tag, classes[(tag.taggables_count - min) / div]
    end
  end
	
end
