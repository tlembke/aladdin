class CreateItemnumbers < ActiveRecord::Migration
  def change
    create_table :itemnumbers do |t|
      t.string :name
      t.string :mbs

      t.timestamps null: false
    end
  end
end
