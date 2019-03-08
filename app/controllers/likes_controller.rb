class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @like = current_user.likes.build(like_params)
    @product = @like.product
    if @like.save
      @is_liked = @like
      respond_to :js
    else
      flash[:alert] = "Something went wrong..."
    end
  end

  def destroy
    @like = Like.find(params[:id])
    @product = @like.product
    if @like.destroy
      respond_to :js
    else
      flash[:alert] = "Something went wrong..."
    end
  end

  private
  def like_params
    params.permit(:user_id, :product_id)
  end
end
