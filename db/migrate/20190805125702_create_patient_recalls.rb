class CreatePatientRecalls < ActiveRecord::Migration
  def change
    create_table :patient_recalls do |t|
      t.integer :recall_id
      t.integer :patient_id
      t.integer :everyNumber
      t.string :everyUnit
      t.integer :nextDay
      t.integer :nextMonth
      t.integer :nextYear
      t.boolean :exactDate

      t.timestamps null: false
    end
  end
end
