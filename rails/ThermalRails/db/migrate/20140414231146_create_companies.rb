class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :up_votes
      t.integer :down_votes

      t.timestamps
    end
  end
end
