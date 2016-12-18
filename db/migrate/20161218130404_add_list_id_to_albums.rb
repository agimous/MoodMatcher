class AddListIdToAlbums < ActiveRecord::Migration[5.0]
  def change
    add_column :albums, :list_id, :integer
    add_index :albums, :list_id
  end
end
