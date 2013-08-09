# webserver
------------------
php environment with nginx, phpfpm, phpredis

# Installation
------------------
~~~
git clone https://github.com/remrain/webserver.git
cd webserver && make && make install
cp output /path/to/your/webserver
~~~

# Start
------------------
modify configures under ./etc:
php.ini, php-fpm.conf, nginx.conf

start webserver
~~~
./bin/control start
curl http://localhost:8080
~~~

put your php and static file in htdocs/php, htdocs/front

# CONTACT
------------------
Mail bug reports and suggestions to <chenyaosf@gmail.com>
