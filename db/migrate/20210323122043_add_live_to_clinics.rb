class AddLiveToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :live, :boolean
  end
end
