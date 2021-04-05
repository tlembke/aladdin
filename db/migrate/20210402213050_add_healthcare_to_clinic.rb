class AddHealthcareToClinic < ActiveRecord::Migration
  def change
    add_column :clinics, :healthcare, :boolean
  end
end
