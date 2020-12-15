class CreateDocs < ActiveRecord::Migration
  def change
    create_table :docs do |t|
      t.string :name
      t.string :filename
      t.string :thumbnail
      t.text :description
      t.integer :cat

      t.timestamps null: false
    end
  end
end
