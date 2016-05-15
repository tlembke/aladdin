class CreateMeasurevalues < ActiveRecord::Migration
  def change
    create_table :measurevalues do |t|
      t.integer :patient_id
      t.integer :measure_id
      t.integer :value
      t.date :measuredate

      t.timestamps null: false
    end
  end
end
