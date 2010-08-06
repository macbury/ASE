class SourceRefreshJob < Struct.new(:source_id)
  def perform
		Source.find(source_id).parse
  end    
end 