class RenameRegisterPatientsToRegisterPatients < ActiveRecord::Migration
  def change
  	rename_table :registers_patients, :register_patients
  end
end
