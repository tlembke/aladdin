class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :image_data

      t.timestamps null: false
    end
  end
end
