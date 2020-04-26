class RenameTypeInDocuments < ActiveRecord::Migration
  def change
  	rename_column :documents, :type, :code
  end
end
