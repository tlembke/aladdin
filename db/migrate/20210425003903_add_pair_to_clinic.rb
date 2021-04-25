class AddPairToClinic < ActiveRecord::Migration
  def change
    add_column :clinics, :pair1, :integer
    add_column :clinics, :pair2, :integer
    add_column :clinics, :pair3, :integer
  end
end
