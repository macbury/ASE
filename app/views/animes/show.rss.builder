xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@anime.name} - New Episodes"
    xml.link anime_url(@anime)
    
    for episode in @episodes
      xml.item do
        xml.title "#{t('anime.episode')} #{episode.number}: #{episode.title || t('anime.no_title')}"
        xml.description truncate(episode.description, :length => 512)
        xml.pubDate episode.aired_at.to_s(:rfc822)
        xml.link anime_url(@anime) + "#episode_#{episode.number}"
        xml.guid anime_url(@anime) + "#episode_#{episode.number}"
      end
    end
  end
end