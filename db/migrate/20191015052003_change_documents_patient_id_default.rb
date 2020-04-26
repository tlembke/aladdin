class ChangeDocumentsPatientIdDefault < ActiveRecord::Migration
  def change
  	change_column_default :documents, :patient_id, 0
  end
end
