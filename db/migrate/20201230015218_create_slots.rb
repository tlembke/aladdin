class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.datetime :appointment
      t.integer :doctor_id
      t.integer :patient_id
      t.string :patient_name
      t.integer :apptype
      t.boolean :available

      t.timestamps null: false
    end
  end
end
