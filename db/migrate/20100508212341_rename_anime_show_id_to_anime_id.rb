class RenameAnimeShowIdToAnimeId < ActiveRecord::Migration
  def self.up
		rename_column :episodes, :show_id, :anime_id
  end

  def self.down
  end
end
