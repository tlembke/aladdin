class AddAuditToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :audit, :boolean, default: false
  end
end
