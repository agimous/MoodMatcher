class ListsController < ApplicationController
	def new
    
	end
  
  def create
    @user = User.find(params[:user_id])
	@list = @user.lists.create(list_create_params)
    redirect_to user_path(@user)
  end
  
  def show
    
  end
  
  def update
  
  end
  
  def destroy
	@user = User.find(params[:user_id])
	@list = @user.lists.find(params[:id])
	@list.destroy
    redirect_to user_path(@user)
  end
  
  private
    def list_create_params
      params.require(:list).permit(:name)
    end
  
	def list_delete_params
      params.require(:list).permit(:id)
    end
  
end
