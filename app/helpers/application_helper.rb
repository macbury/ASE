module ApplicationHelper
	def rss_link(title, path)
    tag :link, :type => 'application/rss+xml', :title => title, :href => path, :rel => "alternate"
  end
end
