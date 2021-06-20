class AddContactToBookers < ActiveRecord::Migration
  def change
    add_column :bookers, :email, :string
    add_column :bookers, :mobile, :string
  end
end
