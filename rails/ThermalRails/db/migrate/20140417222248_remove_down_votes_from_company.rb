class RemoveDownVotesFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :down_votes, :integer
  end
end
