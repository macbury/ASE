class CreateTaggables < ActiveRecord::Migration
  def self.up
    create_table :taggables do |t|
      t.integer :anime_id
      t.integer :tag_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taggables
  end
end
