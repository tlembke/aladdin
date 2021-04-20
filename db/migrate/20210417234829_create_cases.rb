class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.string :code,  null:false
      t.integer :patient_id
      t.text :message

      t.timestamps null: false
    end
    add_index :cases, :code, unique: true
  end
end
