class SearchController < ApplicationController
  def search
    if params[:term].nil?
      @products = []
    else
      @products = Product.search params[:term]
    end
  end
end
