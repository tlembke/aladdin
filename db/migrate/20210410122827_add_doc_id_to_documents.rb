class AddDocIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :doc_id, :integer
  end
end
