class CreateAlbums < ActiveRecord::Migration[5.0]
  def change
    create_table :albums do |t|
      t.string :artist
      t.string :name
      t.string :cover
      t.string :genre

      t.timestamps
    end
  end
end
