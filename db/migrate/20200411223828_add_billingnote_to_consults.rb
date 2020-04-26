class AddBillingnoteToConsults < ActiveRecord::Migration
  def change
    add_column :consults, :billingnote, :string
  end
end
