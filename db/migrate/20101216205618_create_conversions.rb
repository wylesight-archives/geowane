class CreateConversions < ActiveRecord::Migration
  def self.up
    create_table :conversions, :force => true do |t|
      t.string :input_file_name
      t.string :input_content_type, :string
      t.integer :input_file_size, :integer
      t.enum :input_format
      t.datetime :input_updated_at, :datetime
      t.string :output_file_name
      t.string :output_content_type, :string
      t.integer :output_file_size, :integer
      t.enum :output_format
      t.datetime :output_updated_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :conversions
  end
end
