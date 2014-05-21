class AddVoteLocationToComparison < ActiveRecord::Migration
  def change
    add_column :comparisons, :vote_location, :string
  end
end
