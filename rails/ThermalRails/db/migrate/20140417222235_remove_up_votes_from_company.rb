class RemoveUpVotesFromCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :up_votes, :integer
  end
end
