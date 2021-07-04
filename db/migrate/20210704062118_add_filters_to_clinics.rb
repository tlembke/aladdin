class AddFiltersToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :shownew, :boolean, default: false
    add_column :clinics, :inviteold, :boolean, default: false
    add_column :clinics, :invitenew, :boolean, default: false
    change_column_default :clinics, :live, false
  end
end
