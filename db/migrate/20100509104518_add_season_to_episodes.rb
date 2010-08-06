class AddSeasonToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :season, :integer, :default => 0
  end

  def self.down
    remove_column :episodes, :season
  end
end
