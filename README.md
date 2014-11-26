SRDB README
=================


Project Specifications
----------------------
This is based on the Search and Replace Db library (https://github.com/interconnectit/Search-Replace-DB). This project ports the search and replace functionality to a .phar, which can then be used in conjunction with a db sync script to handle search and replace functionality on databases that use serialized data.

Setting Up
-------------
* You'll need to update your php.ini settings so that phar.readonly=Off.
* Once that's complete, you can use Box2 (https://github.com/box-project/box2) to generate your .phar.
* Use the command 'php box.phar build' to package your files into a .phar
* The stub is bin/main, in this case, all it does is require the srdb cli file
* The functionality is implemented within the /src/ directory


Dependencies
------------

Box2 (https://github.com/box-project/box2)

Use
------------
* /usr/bin/php srdb.phar <args> - See https://github.com/interconnectit/Search-Replace-DB for CLI script usage
* /usr/bin/php /var/www/srdb.phar -h localhost -uroot -p1234 -n dpname -s www.atlanticbt.com -r abt.dev

Use In Project
------------
* Import the srdb.phar into your project, the appropriate directory is not super critical, but will affect the path described above.
* Within your project's db sync script, reference the "Use" section of this readme to include the necessary command to handle the search and replace functionality.
* Currently included is a sample WordPress db sync script (sync-qa-db.wordpress.sample.sh) with an example of how srdb.sh may be used.