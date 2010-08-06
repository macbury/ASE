class RenameColumnAnimdbIdToAnidbIdInAnime < ActiveRecord::Migration
  def self.up
		rename_column :animes, :animdb_id, :anidb_id
  end

  def self.down
  end
end
