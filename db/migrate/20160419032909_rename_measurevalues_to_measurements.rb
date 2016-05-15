class RenameMeasurevaluesToMeasurements < ActiveRecord::Migration
  def change
  	rename_table :measurevalues, :measurements
  end
end
