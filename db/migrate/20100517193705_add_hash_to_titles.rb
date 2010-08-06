class AddHashToTitles < ActiveRecord::Migration
  def self.up
    add_column :titles, :hashed_name, :string
  end

  def self.down
    remove_column :titles, :hashed_name
  end
end
