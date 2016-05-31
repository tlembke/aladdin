class CreatePhonetimes < ActiveRecord::Migration
  def change
    create_table :phonetimes do |t|
      t.integer :doctor_id
      t.text :message

      t.timestamps null: false
    end
  end
end
