class CreateAnimes < ActiveRecord::Migration
  def self.up
    create_table :animes do |t|
      t.string :name
			t.text :description
			t.string :poster_url
			t.string :permalink
      t.integer :episodes_count

      t.timestamps
    end
  end

  def self.down
    drop_table :animes
  end
end
