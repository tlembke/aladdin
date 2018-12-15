class RenamePatientIdToResultId < ActiveRecord::Migration
  def change
  	rename_column :results, :patient_id, :result_id
  end
end
