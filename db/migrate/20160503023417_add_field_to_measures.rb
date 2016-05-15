class AddFieldToMeasures < ActiveRecord::Migration
  def change
  	add_column :measures, :field, :string
  end
end
