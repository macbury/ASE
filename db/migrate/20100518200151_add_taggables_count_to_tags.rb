class AddTaggablesCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :taggables_count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :taggables_count
  end
end
