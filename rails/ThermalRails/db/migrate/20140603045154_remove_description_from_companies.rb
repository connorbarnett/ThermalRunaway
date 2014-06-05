class RemoveDescriptionFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :description, :string
  end
end
