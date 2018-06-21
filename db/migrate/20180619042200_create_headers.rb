class CreateHeaders < ActiveRecord::Migration
  def change
    create_table :headers do |t|
      t.string :name
      t.string :type
      t.boolean :special

      t.timestamps null: false
    end
  end
end
