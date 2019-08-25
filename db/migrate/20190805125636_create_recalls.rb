class CreateRecalls < ActiveRecord::Migration
  def change
    create_table :recalls do |t|
      t.text :title
      t.integer :cat

      t.timestamps null: false
    end
  end
end
