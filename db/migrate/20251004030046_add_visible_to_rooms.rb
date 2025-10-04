class AddVisibleToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :visible, :boolean, default: false
  end
end
