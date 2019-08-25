class FixRecall < ActiveRecord::Migration
  def change
  	rename_column :members, :recall, :recallflag
  end
end
