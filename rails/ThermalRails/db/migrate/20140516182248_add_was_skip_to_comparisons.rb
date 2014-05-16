class AddWasSkipToComparisons < ActiveRecord::Migration
  def change
    add_column :comparisons, :was_skip, :boolean
  end
end
