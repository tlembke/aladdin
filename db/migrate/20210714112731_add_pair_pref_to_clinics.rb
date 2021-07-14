class AddPairPrefToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :pairpref, :integer
  end
end
