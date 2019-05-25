class Order < ApplicationRecord
  has_many :line_items, :dependent => :destroy
  belongs_to :user

  validates :name, :address, :email, :phone, :presence => true

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def paypal_url(return_path, order)
    values = {
        business: "nguyenvanduong.vn.k59-facilitator@gmail.com",
        cmd: "_xclick",
        upload: 1,
        return: "#{Rails.application.secrets.app_host}#{return_path}",
        invoice: id,
        amount: order.line_items.reduce(0){|sum, line_item| sum + line_item.total_price},
        notify_url: "#{Rails.application.secrets.app_host}/hook"
    }
    "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
  end
end
