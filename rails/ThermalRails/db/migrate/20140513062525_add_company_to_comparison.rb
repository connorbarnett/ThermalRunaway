class AddCompanyToComparison < ActiveRecord::Migration
  def change
    add_reference :comparisons, :company, index: true
  end
end
