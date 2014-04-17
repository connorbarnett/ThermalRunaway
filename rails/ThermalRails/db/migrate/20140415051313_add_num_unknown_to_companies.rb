class AddNumUnknownToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :num_unknown, :integer
  end
end
