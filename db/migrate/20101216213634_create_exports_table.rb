class CreateExportsTable < ActiveRecord::Migration

  def self.up
    create_table :exports, :force => true do |t|
      t.integer :locations_count
      t.references :user, :foreign_key => true
      t.string :output_file_name
      t.string :output_content_type, :string
      t.integer :output_file_size, :integer
      t.enum :output_format
      t.datetime :output_updated_at, :datetime
      t.timestamps
    end
    add_column :exports, :output_platform, :string
    add_column :exports, :name, :string
  end

  def self.down
    drop_table :exports
  end

end