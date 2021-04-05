class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.integer :genie_id
      t.integer :type
      t.string :name
      t.boolean :online, default: true

      t.timestamps null: false
    end
  end
end
