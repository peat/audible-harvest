class CreateTreasures < ActiveRecord::Migration
  def self.up
    create_table :treasures do |t|
      t.timestamps
      t.string :person
      t.string :track
      t.string :artist
      t.string :provider
      t.string :origin
    end

    [:person, :track, :artist, :provider, :origin].each do |c|
      add_index :treasures, c
    end
  end

  def self.down
    drop_table :treasures
  end
end
