class DropJoinTableAlbumsLists < ActiveRecord::Migration[5.0]
  def change
	drop_join_table :albums, :lists
  end
end
