#!/bin/bash

if [ `whoami` != "root" ]
then
	echo "I need to be root in order to install nexflow"
	echo "Quitting"
	exit
fi

type ruby >> /dev/null

if [ $? -ne 0 ]
then
	apt-get install curl
	bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
	
	source /etc/profile.d/rvm.sh

	echo "source /etc/profile.d/rvm.sh" >> ~/.bash_profile

	apt-get install -y libssl-dev build-essential libxslt-dev libpq-dev
	rvm install 1.9.3
	rvm use 1.9.3
	gem install bundler
	gem install rails
fi

type gem >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need rubygems installed. This should have been installed with RVM."
	exit 1
fi

type bundle >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need the bundler gem installed (gem install bundler). This should have been installed with RVM."
	exit 1
fi

type rails >> /dev/null

if [ $? -ne 0 ]
then
	echo "I need rails installed. This should have been installed with RVM."
	exit 1
fi

type git >> /dev/null

if [ $? -ne 0 ]
then
	apt-get install -y git-core
fi

apt-get install -y postgresql-9.1 postgresql-contrib-9.1
echo -e "\n\n\n\n\n\n\nPlease enter the new password for the \"postgres\" user."
echo "\\password" | sudo -u postgres psql

git clone git://github.com/rapid7/workflow-client.git /opt/nexflow || exit 1

cd /opt/nexflow || exit 1

bundle install || exit 1

#not always needed, but have needed in the past. Can't hurt.
bundle update || exit 1

cp config/database.yml.bak config/database.yml || exit 1

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

rake db:create || exit 1
rake db:migrate || exit 1
rake db:seed || exit 1

exit 0
