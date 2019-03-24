class SearchController < ApplicationController
  def search
    if params[:term].nil?
      @products = []
    else
      @products = Product.search params[:term]
    end
    @size = @products.size

    @products = Kaminari.paginate_array(@products).page(params[:page]).per(8)
  end
end
