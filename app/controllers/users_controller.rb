class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @liked = current_user.likes
  end

  def purchase_history
    @orders = current_user.orders
  end
end
