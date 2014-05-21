class AddDeviceIdToComparison < ActiveRecord::Migration
  def change
    add_column :comparisons, :device_id, :string
  end
end
