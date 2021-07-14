class AddPairsToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :pairmin, :integer
    add_column :clinics, :pairmax, :integer
  end
end
