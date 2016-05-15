class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :patient_id
      t.integer :genie_id
      t.text :note

      t.timestamps null: false
    end
  end
end
