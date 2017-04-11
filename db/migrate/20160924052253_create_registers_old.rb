class CreateRegistersOld < ActiveRecord::Migration
  def change
    create_table :registers do |t|
      t.integer :register_id
      t.integer :patient_id

      t.timestamps null: false
    end
  end
end
