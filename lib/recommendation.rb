module Recommendation
  def recommend_products # recommend products to a user

    # find all other users, equivalent to .where(‘id != ?’, self.id)
    other_users = self.class.all.where.not(id: self.id)

    # instantiate a new hash, set default value for any keys to 0
    recommended = Hash.new(0)

    # for each user of all other users
    other_users.each do |user|

      # find the products this user and another user both liked
      # nhung phim ma cac user khac va user dang xet deu xem
      common_products = user.products & self.products

      # calculate the weight (recommendation rating)
      # tinh trong so
      weight = common_products.size.to_f / user.products.size

      # add the extra products the other user liked
      (user.products - common_products).each do |product|
        # put the product along with the cumulative weight into hash
        recommended[product] += weight
      end
    end

    # sort by weight in descending order
    sorted_recommended = recommended.sort_by { |key, value| value }.reverse
  end
end
