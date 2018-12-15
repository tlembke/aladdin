class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.date :result_date
      t.integer :patient_id
      t.boolean :printed

      t.timestamps null: false
    end
  end
end
