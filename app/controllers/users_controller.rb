class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @liked = current_user.likes
  end
end
