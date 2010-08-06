class AddHentaiToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :hentai, :boolean, :default => false
  end

  def self.down
    remove_column :animes, :hentai
  end
end
