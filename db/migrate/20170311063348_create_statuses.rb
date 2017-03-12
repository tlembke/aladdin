class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :status
      t.integer :patient_id
      t.integer :condition_id

      t.timestamps null: false
    end
  end
end
