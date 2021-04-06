class AddEligibilityToBooker < ActiveRecord::Migration
  def change
    add_column :bookers, :eligibility, :integer
  end
end
