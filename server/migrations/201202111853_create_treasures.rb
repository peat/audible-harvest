class CreateTreasures < ActiveRecord::Migration
  def self.up
    create_table :treasures do
      t.timestamps
    end
  end

  def self.down
    drop_table :treasures
  end
end
