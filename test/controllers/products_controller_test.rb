require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post products_url, params: { product: { brand: @product.brand, crawl_timestamp: @product.crawl_timestamp, description: @product.description, discounted_price: @product.discounted_price, image: @product.image, is_FK_Advantage_product: @product.is_FK_Advantage_product, overall_rating: @product.overall_rating, pid: @product.pid, product_category_tree: @product.product_category_tree, product_name: @product.product_name, product_rating: @product.product_rating, product_specifications: @product.product_specifications, product_url: @product.product_url, retail_price: @product.retail_price, uniq_id: @product.uniq_id } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { brand: @product.brand, crawl_timestamp: @product.crawl_timestamp, description: @product.description, discounted_price: @product.discounted_price, image: @product.image, is_FK_Advantage_product: @product.is_FK_Advantage_product, overall_rating: @product.overall_rating, pid: @product.pid, product_category_tree: @product.product_category_tree, product_name: @product.product_name, product_rating: @product.product_rating, product_specifications: @product.product_specifications, product_url: @product.product_url, retail_price: @product.retail_price, uniq_id: @product.uniq_id } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
