class AddDeviceIdToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :device_id, :string
  end
end
