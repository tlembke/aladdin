class CreateMeasures < ActiveRecord::Migration
  def change
    create_table :measures do |t|
      t.string :name
      t.string :abbreviation
      t.string :description
      t.string :units
      t.decimal :value
      t.integer :operator
      t.integer :places
      t.boolean :local

      t.timestamps null: false
    end
  end
end
