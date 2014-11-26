#!/bin/sh

###
### This script is designed to sync the database of your local vagrant instance with
### various configured remote environments (qa/dev/production). It is specifically developed with
### WordPress sites in mind, and uses srdb.phar to handle replacing site urls within serialized data.
###
### This script assumes you have a vagrant environment setup and that it's running at the time you run this.
###
### You are free to modify it as necessary to suit your project needs, simply change the filenae to sync-qa-db.sh
### inside your project directory (in other words, don't make changes to this sample script unless those changes
### are intended for all WordPress sites).
###

# get current working directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###
### Step 1: Query User For Environment (production/qa/staging/development/etc)
###

echo "\nFrom which environment? [dev/prod] - Currently the only option is dev. Update sync-qa-db.sh when qa/production is available."
read ENV
if [ "$ENV" = "dev" ]; then
    DBNAME="REPLACE_ME"
    DBHOST="REPLACE_ME"
    DBUSER="REPLACE_ME"
    PW="REPLACE_ME"
    HOST="REPLACE_ME"
    UPLOADSDIR="REPLACE_ME"
elif [ "$ENV" = "prod" ]
then
    # Update these when production values are available
    DBNAME="REPLACE_ME"
    DBHOST="REPLACE_ME"
    DBUSER="REPLACE_ME"
    PW="REPLACE_ME"
    HOST="REPLACE_ME"
    UPLOADSDIR="REPLACE_ME"
else
    echo "Unknown environment. ABORT"
    exit 0
fi

###
### Step 2: Assign local environment variables
###
# In the future, we may want to open these up to allow user input
LOCAL="REPLACE_ME"  # Vagrant Local URL (usually projectname.dev
VDBUSER="REPLACE_ME"
VDBPASS="REPLACE_ME"
VDBNAME="REPLACE_ME"


###
### STEP 3: Use Vagrant instance, take a dump of remote database (as specified by environment)
###
echo "\nPulling QA Server's DB to local $DIR/src/sql/schema.sql\n"
vagrant ssh -c"mysqldump -u$DBUSER -p\"$PW\" -h$DBHOST $DBNAME > \"/var/www/sql/schema.sql\""


###
### STEP 4: Replace instance of remote environment url in db with local environment url
###
echo "\nReplacing DB instances of $HOST to unitedfresh.dev\n"
# Creates a temp db using qa server dump, performs URL replacement, then exports back out
# This is a search & replace that works & doesn't destroy serialized data
vagrant ssh -c"mysql -u$VDBUSER -p$VDBPASS -e 'DROP DATABASE IF EXISTS temp;CREATE DATABASE temp;'"
vagrant ssh -c"mysql -u$VDBUSER -p$VDBPASS temp < /var/www/sql/schema.sql;" # Import WP
vagrant ssh -c "/usr/bin/php /var/www/srdb.phar -h localhost -u$VDBUSER -p$VDBPASS -n temp -s $HOST -r $LOCAL" # Run search & replace
vagrant ssh -c"mysqldump -u$VDBUSER -p$VDBPASS temp > /var/www/sql/schema.sql" # Export sanitized & converted db dump
vagrant ssh -c"mysql -u$VDBUSER -p$VDBPASS -e 'DROP DATABASE temp;'" # Drop temp database


###
### Ideally, if we could get WP-CLI's search & replace to work, then we can drop the commands above
###
# Attempting to use WP-CLI, but search-replace does nothing,
# vagrant ssh -c "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
# vagrant ssh -c "/usr/bin/php wp-cli.phar search-replace '$HOST' '$LOCAL' --path='/var/www/html/wordpress'"

###
### STEP 5: Update local db, if user opts for this
###
# Show notice to user
echo "\n$DIR/sql/schema.sql has been updated. Please be sure to commit these changes.\n"

echo "\nDo you want to overwrite your local database with the QA server's data? [Y/n]";
read APPLY
if [ "$APPLY" = "Y" ]; then
    echo "\nApplying database to your local copy...\n"
    #!/bin/sh

vagrant ssh -c"mysql -u$VDBUSER -p$VDBPASS -e 'DROP DATABASE IF EXISTS $VDBNAME; CREATE DATABASE $VDBNAME;'"
vagrant ssh -c"mysql -u$VDBUSER -p$VDBPASS $VDBNAME < /var/www/sql/schema.sql"
fi


###
### STEP 6: Sync uploads if user opts for this
###
echo echo "\nDo you want to copy down the QA server's uploads directory as well? [Y/n]";
read COPY
if [ "$COPY" = "Y" ]; then
    mkdir -p "$DIR/html/content/uploads"
    echo "\nCopying down QA server uploads directory. Please type QA server ftp password ($PW)\n"
    scp -r ${DBUSER}@${DBHOST}:${UPLOADSDIR}* "$DIR/html/content/uploads"
else
   echo "\nNot copying uploads\n"
fi