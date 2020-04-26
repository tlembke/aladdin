class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.text :description
      t.integer :patient_id
      t.integer :type
      t.integer :parent
      t.string :texttype
      t.text :content

      t.timestamps null: false
    end
  end
end
