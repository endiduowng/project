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

  def chat
    session[:conversations] ||= []

    @users = User.all.where.not(id: current_user)
    @conversations = Conversation.includes(:recipient, :messages)
                                 .find(session[:conversations])
  end

  def recommend_product
    products = Product.all
    @recommend_product = products.select {|product| current_user.prediction_for(product) >= 3}
  end
end
