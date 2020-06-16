class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @favorited = current_user.favorites
  end

  def purchase_history
    @ss = []
    @orders = current_user.orders.where(status: "Completed")
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
    @result_products = products.select {|product| current_user.prediction_for(product) > 0}
    @recommend_products = @result_products.sort.reverse
  end

  def cf_product
    # system('python ./lib/cf.py')
    # @cf_pros = []
    # a = Recommend.find_by(user_id: current_user.id)
    # b = a.recommend_id
    # c = b[1...(b.size - 1)]
    # @ds = c.split(/,/)
    # @ds.each do |ds|
    #   @cf_pros << Product.find_by(id: ds.to_i)
    # end

    # system('python ./lib/cf1.py')
    @cf_pros = []
    a = IRecommend.all
    a.each do |item|
      b = item.recommend_list
      c = b[1...(b.size - 1)]
      @ds = c.split(/,/)
      @ds.each do |ds|
        id = ds.to_i
        if id == current_user.id
          @cf_pros << Product.find_by(id: item.item_id)
        end
      end
    end
  end

  def admin_users
    users = User.all
    @users = Kaminari.paginate_array(users).page(params[:users_page]).per(8)
  end

  def admin_products
    products = Product.all
    @products = Kaminari.paginate_array(products).page(params[:products_page]).per(8)
  end

  def admin_orders
    order = Order.all
    @order =Kaminari.paginate_array(orders).page(params[:orders_page]).per(8)
  end
end
