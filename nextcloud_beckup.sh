#!/bin/bash
YEAR=`date +"%Y"`
MONTH=`date +"%m"`
DAY=`date +"%d"`
# Database credentials ---------------------------
user="root"
password="root"
host="localhost"
db_name="nextcloud"
#create folder and PATH ---------------------------
CREATE_FOLDER=`mkdir -p "/beckap/$YEAR/$MONTH/$DAY"`
DATA="/beckap/$YEAR/$MONTH/$DAY"
#--------------------------------------------------
var_dir=/var/www/data
target_dir=/beckap
#-------------------------------------------------------------------------------------------------------------------------------
#Create mysql dump													       
/usr/bin/mysqldump --single-transaction --host=$host --user=$user  --password=$password $db_name | gzip > $DATA/nextcloud_db.sql.gz               

#create tar.gz ARHIVE
/bin/tar -czvf $DATA/data.tar.gz $var_dir --exclude='some_folder if you nead/*'
#find and delete old archive and old directories
#/usr/bin/find $target_dir -type f -mtime $limit -print0 | xargs -0 rm -f && /usr/bin/find $target_dir -type d -empty -delete
#-------------------------------------------
cd "$target_dir" || exit 1
#--------------------------------------------
LS_DAY=`ls -d */*/*`
LS_MONTH=`ls -d */*`
LS_YEAR=`ls -d *`
TO_DAY=`date +"%Y/%m/%d" --date="today"`
TO_MONTH=`date +"%Y/%m" --date="today"`
TO_YEAR=`date +"%Y" --date="today"`
#------------------------------------------
for SOMEYEAR in $LS_YEAR
do
if
        [[ "$TO_YEAR" > "$SOMEYEAR" ]]
then
rm -r "$SOMEYEAR"
fi
done
#------------------------------------------
for SOMEMONTH in $LS_MONTH
do
if [ -d "$SOMEMONTH" ]; then
if
        [[ "$TO_MONTH" > "$SOMEMONTH" ]]
then
rm -r "$SOMEMONTH"
fi
fi
done
#-------------------------------------------
for SOMEDAY in $LS_DAY
do
if [ -d "$SOMEDAY" ]; then
if
        [[ "$TO_DAY" > "$SOMEDAY" ]]
then
rm -r "$SOMEDAY"
fi
fi
done
#------------------------------------------
/bin/chown -R beckap "$target_dir"

#write to the size directories
/usr/bin/du --si $target_dir > /tmp/list.txt
#--------------------------------------------------------------------------------------------------------------------------------------
scp -r $target_dir root@192.168.0.33:/home/test/google-drive

#Send results to the email
mail -s "backup_nextcloud" root@gmail.com <  /tmp/list.txt
#--------------------------------------------------------------------------------------------------------------------------------------
docker stop collabora && /etc/init.d/mysql stop && /etc/init.d/php7.0-fpm stop && /etc/init.d/memcached stop && /etc/init.d/nginx stop

docker start collabora && /etc/init.d/mysql start && /etc/init.d/php7.0-fpm start && /etc/init.d/memcached start && /etc/init.d/nginx start
