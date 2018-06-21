class RenameTypeInHeaders < ActiveRecord::Migration
	def change
    		rename_column :headers, :type, :code
    end
end
