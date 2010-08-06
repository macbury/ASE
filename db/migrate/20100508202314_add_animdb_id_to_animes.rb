class AddAnimdbIdToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :animdb_id, :integer
  end

  def self.down
    remove_column :animes, :animdb_id
  end
end
