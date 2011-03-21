class CreateLabelsTable < ActiveRecord::Migration

  def self.up
    unless table_exists?(:labels)
      create_table :labels do |t|
        t.string :key, :null => false
        t.string :value, :null => false
        t.string :classification
        t.references :location, :foreign_key => true
        t.timestamps
      end
      add_index :labels, ["key"], :name => "idx_labels_key"
      add_index :labels, ["classification"], :name => "idx_labels_classification"
    end
  end

  def self.down
    drop_table :labels if table_exists?(:labels)
  end

end

