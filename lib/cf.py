import pandas as pd
import numpy as np

import pymysql
import csv

from sklearn.metrics.pairwise import cosine_similarity
from scipy import sparse
from array import array

class CF(object):
    """docstring for CF"""
    def __init__(self, Y_data, k, dist_func = cosine_similarity, uuCF = 1):
        self.uuCF = uuCF # user-user (1) or item-item (0) CF
        self.Y_data = Y_data if uuCF else Y_data[:, [1, 0, 2]]
        self.k = k
        self.dist_func = dist_func
        self.Ybar_data = None
        # number of users and items. Remember to add 1 since id starts from 0
        self.n_users = int(np.max(self.Y_data[:, 0])) + 1 # tinh ra so luong users
        self.n_items = int(np.max(self.Y_data[:, 1])) + 1 # tinh ra so luong items

    def add(self, new_data):
        """
        Update Y_data matrix when new ratings come.
        For simplicity, suppose that there is no new user or item.
        """

        # Cap nhat ma tran Y khi xep hang moi den, de don gian gia su nhu khong co nguoi dung hoac vat pham moi
        self.Y_data = np.concatenate((self.Y_data, new_data), axis = 0)

    # ham chuan hoa
    def normalize_Y(self):
        users = self.Y_data[:, 0] # all users - first col of the Y_data # tat ca users
        self.Ybar_data = self.Y_data.copy()
        self.mu = np.zeros((self.n_users,))
        for n in xrange(self.n_users):
            # row indices of rating done by user n # chi so xep hang duoc thuc hien boi nguoi dung n
            # since indices need to be integers, we need to convert # vi cac chi so can la so nguyen nen can chuyen doi
            ids = np.where(users == n)[0].astype(np.int32)
            # indices of all ratings associated with user n #chi so cua tat ca xep hang lien quan den nguoi dung n, index cua item duoc rate
            item_ids = self.Y_data[ids, 1]
            # and the corresponding ratings # va diem xep hang tuong ung
            ratings = self.Y_data[ids, 2]
            # take mean
            m = np.mean(ratings)
            if np.isnan(m): #kiem tra phan tu m co nan hay ko
                m = 0 # to avoid empty array and nan value
            self.mu[n] = m
            # normalize
            self.Ybar_data[ids, 2] = ratings - self.mu[n]

        ################################################
        # form the rating matrix as a sparse matrix. Sparsity is important
        # for both memory and computing efficiency. For example, if #user = 1M,
        # #item = 100k, then shape of the rating matrix would be (100k, 1M),
        # you may not have enough memory to store this. Then, instead, we store
        # nonzeros only, and, of course, their locations.
        self.Ybar = sparse.coo_matrix((self.Ybar_data[:, 2],
            (self.Ybar_data[:, 1], self.Ybar_data[:, 0])), (self.n_items, self.n_users))
        self.Ybar = self.Ybar.tocsr()

    def similarity(self):
        eps = 1e-6
        self.S = self.dist_func(self.Ybar.T, self.Ybar.T)


    def refresh(self):
        """
        Normalize data and calculate similarity matrix again (after
        some few ratings added)
        """
        self.normalize_Y()
        self.similarity()

    def fit(self):
        self.refresh()


    def __pred(self, u, i, normalized = 1):
        """
        predict the rating of user u for item i (normalized)
        if you need the un
        """
        # Step 1: find all users who rated i
        ids = np.where(self.Y_data[:, 1] == i)[0].astype(np.int32)
        # Step 2:
        users_rated_i = (self.Y_data[ids, 0]).astype(np.int32)
        # Step 3: find similarity btw the current user and others
        # who already rated i
        sim = self.S[u, users_rated_i]
        # Step 4: find the k most similarity users
        a = np.argsort(sim)[-self.k:]
        # and the corresponding similarity levels
        nearest_s = sim[a]
        # How did each of 'near' users rated item i
        r = self.Ybar[i, users_rated_i[a]]
        if normalized:
            # add a small number, for instance, 1e-8, to avoid dividing by 0
            return (r*nearest_s)[0]/(np.abs(nearest_s).sum() + 1e-8)

        return (r*nearest_s)[0]/(np.abs(nearest_s).sum() + 1e-8) + self.mu[u]

    def pred(self, u, i, normalized = 1):
        """
        predict the rating of user u for item i (normalized)
        if you need the un
        """
        if self.uuCF: return self.__pred(u, i, normalized)
        return self.__pred(i, u, normalized)


    def recommend(self, u):
        """
        Determine all items should be recommended for user u.
        The decision is made based on all i such that:
        self.pred(u, i) > 0. Suppose we are considering items which
        have not been rated by u yet.
        """
        ids = np.where(self.Y_data[:, 0] == u)[0]
        items_rated_by_u = self.Y_data[ids, 1].tolist()
        recommended_items = []
        for i in xrange(self.n_items):
            if i not in items_rated_by_u:
                rating = self.__pred(u, i)
                if rating > 0:
                    recommended_items.append(i)

        return recommended_items

    def recommend2(self, u):
        """
        Determine all items should be recommended for user u.
        The decision is made based on all i such that:
        self.pred(u, i) > 0. Suppose we are considering items which
        have not been rated by u yet.
        """
        ids = np.where(self.Y_data[:, 0] == u)[0]
        items_rated_by_u = self.Y_data[ids, 1].tolist()
        recommended_items = []

        for i in xrange(self.n_items):
            if i not in items_rated_by_u:
                rating = self.__pred(u, i)
                if rating > 0:
                    recommended_items.append(i)

        return recommended_items

    def print_recommendation(self, cursor):
        """
        print all items which should be recommended for each user #in ra tat ca cac items ma duoc recommend cho moi user
        """
        for u in xrange(self.n_users):
            recommended_items = self.recommend(u)
            # if self.uuCF:
            #     print '    Recommend item(s):', recommended_items, 'for user', u
            # else:
            #     print '    Recommend item', u, 'for user(s) : ', recommended_items
            sql1 = "SELECT * FROM recommends WHERE user_id = %s"
            sql2 = "INSERT INTO recommends (user_id, recommend_id) VALUES (%s, %s)"
            sql3 = "UPDATE recommends SET recommend_id = %s WHERE user_id = %s"

            row = cursor.execute(sql1, int(u))

            if row > 0:
              cursor.execute(sql3, (str(recommended_items), int(u)))
            else:
              cursor.execute(sql2, (int(u), str(recommended_items)))



# data file

# r_cols = ['user_id', 'item_id', 'rating']
# ratings = pd.read_csv('ex.dat', sep = ' ', names = r_cols, encoding='latin-1')
# Y_data = ratings.as_matrix()

# rs = CF(Y_data, k = 2, uuCF = 0)
# rs.fit()

# rs.print_recommendation()


import pymysql.cursors

connection = pymysql.connect(host='localhost',
                             user='root',
                             password='',
                             db='project',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)


print ("connect successful!!")

try:
    with connection.cursor() as cursor:

        sql = "SELECT user_id, product_id, product_rating FROM reviews"

        cursor.execute(sql)

        results = pd.read_sql(sql, connection)
        results.to_csv('output.dat', index=False, header = None)

        r_cols = ['user_id', 'product_id', 'product_rating']
        ratings = pd.read_csv('output.dat', sep=',',names = r_cols, encoding='latin-1')
        Y_data = ratings.as_matrix()

        rs = CF(Y_data, k = 30, uuCF = 1)
        rs.fit()

        rs.print_recommendation(cursor)
        connection.commit()

        # for item in items:
        #   if self.uuCF:
            #       print '    Recommend item(s):', item, 'for user', u
            #   else:
            #       print '    Recommend item', u, 'for user(s) : ', item

finally:
    connection.close()
