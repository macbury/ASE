class AddAirdateToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :airdate, :date, :default => nil
  end

  def self.down
    remove_column :episodes, :airdate
  end
end
