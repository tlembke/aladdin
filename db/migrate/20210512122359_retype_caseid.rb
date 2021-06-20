class RetypeCaseid < ActiveRecord::Migration
  def change
  	change_column :cases_docs, :case_id, :string
  end
end
