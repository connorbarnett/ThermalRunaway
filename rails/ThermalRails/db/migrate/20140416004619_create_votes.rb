class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.string :company
      t.string :vote_type
      t.string :vote_location

      t.timestamps
    end
  end
end
