class CreateFeaturesTable < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.integer :end_level
      t.boolean :one_way
      t.string :label
      t.integer :level
      t.integer :road_id
      t.integer :road_class
      t.integer :speed
      t.integer :type
    end
    add_column :features, :geom, :geometry, :limit => nil, :srid => 4326
    add_index 'features', %w(geom), :name => 'idx_features_geom', :spatial => true
  end
end
