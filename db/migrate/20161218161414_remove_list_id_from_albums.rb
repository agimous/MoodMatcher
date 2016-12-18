class RemoveListIdFromAlbums < ActiveRecord::Migration[5.0]
  def change
	remove_column :albums, :list_id
  end
end
