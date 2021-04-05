class AddApptIdToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :appt_id, :integer
    add_column :slots, :block_id, :integer
  end
end
