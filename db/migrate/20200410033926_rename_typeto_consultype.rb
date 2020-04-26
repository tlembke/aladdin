class RenameTypetoConsultype < ActiveRecord::Migration
  def change
  	rename_column :consults, :type, :consulttype
  end
end
