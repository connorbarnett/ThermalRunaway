class AddWinningCompanyNameAndLosingCompanyNameToComparison < ActiveRecord::Migration
  def change
    add_column :comparisons, :winning_company_name, :string
    add_column :comparisons, :losing_company_name, :string
  end
end
