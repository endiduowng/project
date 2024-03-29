class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @product = Product.find(params[:product_id])
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
    @review = Review.find(params[:id])
    @product = @review.product
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @product = Product.find(params[:product_id])
    @review = @product.reviews.build(review_params)

    respond_to do |format|
      if !@review.product_rating
          format.html { redirect_to @product, alert: 'Review was error created.' }
      else
        if @review.save
          score = @product.reviews.average(:product_rating)
          @product.update_attributes overall_rating: score

          if @review.product_rating >= 3
            current_user.like(@product)
          else
            current_user.dislike(@product)
          end

          format.html { redirect_to @product, notice: 'Review was successfully created.' }
          format.json { render :show, status: :created, location: @review }
        else
          format.html { render :new }
          format.json { render json: @review.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    @product = @review.product
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @product, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @product = @review.product
    @review.destroy
    respond_to do |format|
      format.html { redirect_to @product, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:product_rating, :comment, :product_id, :user_id)
    end
end
