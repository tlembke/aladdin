class CreateBookers < ActiveRecord::Migration
  def change
    create_table :bookers do |t|
      t.integer :clinic_id
      t.integer :genie
      t.string :surname
      t.string :firstname
      t.date :dob
      t.string :vaxtype
      t.integer :contactby
      t.boolean :confirm
      t.datetime :received
      t.integer :arm
      t.integer :dose
      t.string :batch
      t.string :note

      t.timestamps null: false
    end
  end
end
