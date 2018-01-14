require 'fileutils'
require 'pathname'

class UsersController < ApplicationController
  def show
    begin
      @user = User.find(params[:id])
      if @user == current_user then
        @requests = Request.where(user_id: current_user[:id])
      else
        redirect_to root_path
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path
    end


    
  end
  
  def new
  	@user = User.new
  end

  def del
    tag_ids = params[:tag_ids]
    unless tag_ids.nil? then
      tag_ids.each do |tid| 
        r = Request.find_by(id: tid.to_i)
        path = Rails.root.to_s + $classifier_images_path + r.name
        if Pathname.new(path).file? 
          FileUtils.rm(path)
        end
        r.destroy
      end
    end

    redirect_to current_user
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      log_in @user
  		flash[:success] = "Welocome to Cloud Classifier!"
  		redirect_to @user
  	else
  		render 'new'
  	end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end


end
