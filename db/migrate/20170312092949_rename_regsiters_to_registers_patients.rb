class RenameRegsitersToRegistersPatients < ActiveRecord::Migration
  def change
  	rename_table :registers, :registers_patients
  end
end
