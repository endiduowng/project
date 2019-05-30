How to run
Setup development environment:

Go here: https://gorails.com/setup, choose your OS's version and following instructions to install Ruby, Rails and MySQL.
Download source code, library:

Download source code and open terminal inside it:

$ cd project

Then install library:

$ bundle install

Create database, table and data

Update MySQL's username, password to file database.yml

Create database:

$ rails db:create

Create tables using migration:

$ rails db:migrate

Seed some data to database:

$ rails db:seed

Go here: https://iridakos.com/tutorials/2017/12/03/elasticsearch-and-rails-tutorial.html to install elasticsearch

Go here: https://ngrok.com/download to install ngrok(the environment which support payment by paypal)

Install python to compile python file(to run recommended algorithm):

$ sudo apt-get install python

then install pymysql:
$ sudo apt-get install python3-pymysql

Server

Finally, run rails server:

$ rails server

Open browser and go to address: "localhost:3000"

Hope you enjoy it!
