class AddPatientIdToResults < ActiveRecord::Migration
  def change
  	add_column :results, :patient_id, :integer
  end
end
