class CreateJoinTableDocTag < ActiveRecord::Migration
  def change
    create_join_table :docs, :tags do |t|
      # t.index [:doc_id, :tag_id]
      # t.index [:tag_id, :doc_id]
    end
  end
end
