class AddScaleToMeasures < ActiveRecord::Migration
  def change
  	add_column :measures, :scale, :integer
  end
end
