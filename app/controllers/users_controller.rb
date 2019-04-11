class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @liked = current_user.likes
  end

  def purchase_history
    @ss = []
    @orders = current_user.orders
    if @orders != nil
      @orders.each do |order|
        @line_items = order.line_items
        @line_items.each do |line_item|
          @item = line_item.product
          @products = Product.search("#{@item.product_category_tree.split(/>>/).reverse.second}")
          @products.each do |product|
            @ss << product
          end
        end
      end
      size = @ss.size
      @product1 = @ss[rand(size)]
      @product2 = @ss[rand(size)]
      @product3 = @ss[rand(size)]
      @product4 = @ss[rand(size)]
    end
  end
end
