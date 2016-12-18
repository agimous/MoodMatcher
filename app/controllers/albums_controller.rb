class AlbumsController < ApplicationController
	def create
		@user = User.find(params[:user_id])
		@list = @user.lists.find(params[:list_id])
		@album = @list.albums.create(album_create_params)
		redirect_to user_path(@user)
	end
	
	
	
private
	def album_create_params
      params.require(:list).permit(:name)
    end
	
	
end
