class AddIdsToComparison < ActiveRecord::Migration
  def change
    add_reference :comparisons, :winning_company, index: true
    add_reference :comparisons, :losing_company, index: true
  end
end
