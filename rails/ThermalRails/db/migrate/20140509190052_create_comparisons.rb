class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|
      t.string :winningCompany
      t.string :losingCompany
      t.string :deviceId
      t.string :voteLocation

      t.timestamps
    end
  end
end
