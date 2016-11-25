class MoodsController < ApplicationController
	
	def index
		@moods = Mood.all
	end
	
	def show
		@mood = Mood.find(params[:id])
	end
	
	def new
	end
	
	def create
		@mood = Mood.new(params.require(:mood).permit(:name))
 
		@mood.save
		redirect_to moods_url
	end
	
	def destroy
		@mood = Mood.find(params[:id])
 
		@mood.destroy
		redirect_to moods_url
	end
	
end
