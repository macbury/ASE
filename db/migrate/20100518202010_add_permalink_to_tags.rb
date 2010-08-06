class AddPermalinkToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :permalink, :string

		Tag.all.each do |tag|
			tag.create_permalink
			tag.save
		end
  end

  def self.down
    remove_column :tags, :permalink
  end
end
