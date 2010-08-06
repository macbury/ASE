class AddTrailerUrlToAnimes < ActiveRecord::Migration
  def self.up
    add_column :animes, :trailer_url, :string
  end

  def self.down
    remove_column :animes, :trailer_url
  end
end
