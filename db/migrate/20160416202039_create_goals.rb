class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :title
      t.text :description
      t.integer :condition_id
      t.integer :patient_id
      t.integer :measure_id
      t.integer :active
      t.integer :parent

      t.timestamps null: false
    end
  end
end
