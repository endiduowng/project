json.extract! product, :id, :uniq_id, :crawl_timestamp, :product_url, :product_name, :product_category_tree, :pid, :retail_price, :discounted_price, :image, :is_FK_Advantage_product, :description, :product_rating, :overall_rating, :brand, :product_specifications, :created_at, :updated_at
json.url product_url(product, format: :json)
