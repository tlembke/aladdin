class RenameValueinMeasuresToTarget < ActiveRecord::Migration
  def change
  	rename_column :measures, :value, :target
  end
end
