class CreateMasters < ActiveRecord::Migration
  def change
    create_table :masters do |t|
      t.string :name
	  t.timestamps null: false
    end
  end
end
