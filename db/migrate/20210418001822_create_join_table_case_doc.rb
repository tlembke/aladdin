class CreateJoinTableCaseDoc < ActiveRecord::Migration
  def change
    create_join_table :cases, :docs do |t|
      # t.index [:case_id, :doc_id]
      # t.index [:doc_id, :case_id]
    end
  end
end
