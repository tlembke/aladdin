class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.text :chapter
      t.integer :section_id
      t.integer :position

      t.timestamps null: false
    end
  end
end
