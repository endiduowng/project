class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :image, :image_cache, :remove_image])
  end

  private

    def current_cart
        Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
        cart = Cart.create
        session[:cart_id] = cart.id
        cart
    end

    def random_product
      random_product = Product.all[rand(400)]
    end

    def recent_products
      @recent_products ||= RecentProducts.new cookies
    end

    def last_viewed_product
      recent_products.reverse.second
    end

  helper_method :current_cart
  helper_method :random_product

  helper_method [:recent_products, :last_viewed_product]
end
