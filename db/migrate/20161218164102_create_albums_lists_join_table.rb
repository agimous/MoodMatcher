class CreateAlbumsListsJoinTable < ActiveRecord::Migration[5.0]
  def change
	create_join_table :albums, :lists
  end
end
