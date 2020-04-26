class CreateConsults < ActiveRecord::Migration
  def change
    create_table :consults do |t|
      t.integer :provider_id
      t.integer :patient_id
      t.datetime :consultdate
      t.string :mbs
      t.string :type
      t.text :notes
      t.boolean :billed
      t.boolean :complete

      t.timestamps null: false
    end
  end
end
