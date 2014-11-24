SRDB README
=================


Project Specifications
----------------------
This is based on the Search and Replace Db library (https://github.com/interconnectit/Search-Replace-DB). This project ports the search and replace functionality to a .phar, which can then be used in conjunction with a db sync script to handle search and replace functionality on databases that use serialized data.

Setting Up
-------------
You'll need to update your php.ini settings so that phar.readonly=Off.
Once that's complete, you can use Box2 (https://github.com/box-project/box2) to generate your .phar.


Dependencies
------------

Box2 (https://github.com/box-project/box2)

Use
------------
/usr/bin/php srdb.phar <args> - See https://github.com/interconnectit/Search-Replace-DB for CLI script usage
/usr/bin/php /var/www/srdb.phar -h localhost -uroot -p1234 -n dpname -s www.atlanticbt.com -r abt.dev