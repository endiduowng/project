class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @favorite = current_user.favorites.build(favorite_params)
    @product = @favorite.product
    if @favorite.save
      @is_favorited = @favorite
      respond_to :js
    else
      flash[:alert] = "Something went wrong..."
    end
  end

  def destroy
    @favorite = Favorite.find(params[:id])
    @product = @favorite.product
    if @favorite.destroy
      respond_to :js
    else
      flash[:alert] = "Something went wrong..."
    end
  end

  private
  def favorite_params
    params.permit(:user_id, :product_id)
  end
end
