class AddPeopleToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :people, :integer, :default => 25
  end
end
