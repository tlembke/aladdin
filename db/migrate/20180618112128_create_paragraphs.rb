class CreateParagraphs < ActiveRecord::Migration
  def change
    create_table :paragraphs do |t|
      t.integer :patient_id
      t.integer :chapter_id
      t.text :paragraph
      t.boolean :show

      t.timestamps null: false
    end
  end
end
