class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|

      t.timestamps
    end
  end
end
