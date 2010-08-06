class AddMainToTitles < ActiveRecord::Migration
  def self.up
    add_column :titles, :main, :boolean
  end

  def self.down
    remove_column :titles, :main
  end
end
