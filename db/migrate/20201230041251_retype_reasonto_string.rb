class RetypeReasontoString < ActiveRecord::Migration
  def change
  	change_column :slots, :apptype, :string
  end
end
