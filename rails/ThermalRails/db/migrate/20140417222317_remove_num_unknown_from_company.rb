class RemoveNumUnknownFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :num_unknown, :integer
  end
end
