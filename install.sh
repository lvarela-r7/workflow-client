#!/bin/bash

if [ `whoami` != "root" ]
then
	echo "I need to be root in order to install nexflow"
	echo "Quitting"
	exit 255
fi

type ruby >> /dev/null

if [ $? -ne 0 ]
then
	apt-get install curl
	curl -L get.rvm.io | bash -s stable
	source /etc/profile
	rvm pkg install zlib
	rvm pkg install openssl
	apt-get install build-essential
	apt-get install libxml2
	apt-get install libssl-dev libxslt-dev libpq-dev
	rvm install 1.9.3
	rvm use 1.9.3
	gem install rails
fi

type gem >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need rubygems installed. This should have been installed with RVM."
	exit 255
fi

type bundle >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need the bundler gem installed (gem install bundler). This should have been installed with RVM."
	exit 255
fi

type rails >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need rails installed. This should have been installed with RVM."
	exit 255
fi

type git >> /dev/null

if [ $? -ne 0 ]
then
	apt-get install git
fi

apt-get install -y postgresql-9.1 postgresql-contrib-9.1

sed -i 's/5432/5433/' /etc/postgresql/9.1/main/postgresql.conf

/etc/init.d/postgresql restart

echo -e "\n\n\n\n\n\n\nPlease enter the new password for the \"postgres\" user."
echo "\\password" | sudo -u postgres psql -p 5433

git clone git://github.com/rapid7/workflow-client.git /opt/nexflow || exit 255

cd /opt/nexflow || exit 255

git checkout stable

bundle install || exit 255

#not always needed, but have needed in the past. Can't hurt.
bundle update || exit 255

cp config/database.yml.bak config/database.yml || exit 255

echo "What is the postgresql host?"
read PGHOST

echo "What is the postgresql port?"
read PGPORT

echo "What is the postgresql user?"
read PGUSER

echo "What is the postgresql password?"
read PGPASS  #read -sp doesn't echo

sed -i "s/host: 127.0.0.1/host: $PGHOST/" config/database.yml
sed -i "s/port: 5422/port: $PGPORT/" config/database.yml
sed -i "s/port: 5433/port: $PGPORT/" config/database.yml
sed -i "s/username: postgres/username: $PGUSER/" config/database.yml
sed -i "s/password: msf3Password/password: $PGPASS/" config/database.yml
sed -i "s/password: password/password: $PGPASS/" config/database.yml

rake db:create || exit 255
rake db:migrate || exit 255
rake db:seed || exit 255

echo -e "\n\n\nNexflow is now installed. Change to the /opt/nexflow directory and begin the application with:"
echo -e "\n\tcd /opt/nexflow && rails server webrick -e development -p 3000"

exit 0
