class CreateCells < ActiveRecord::Migration
  def change
    create_table :cells do |t|
      t.integer :register_id
      t.integer :patient_id
      t.integer :header_id
      t.string :value
      t.date :date
      t.text :note

      t.timestamps null: false
    end
  end
end
