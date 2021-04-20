class AddBreaksToClinic < ActiveRecord::Migration
  def change
    add_column :clinics, :break, :boolean
    add_column :clinics, :bstarthour, :integer
    add_column :clinics, :bstartminute, :integer
    add_column :clinics, :bfinishhour, :integer
    add_column :clinics, :bfinishminute, :integer
  end
end
