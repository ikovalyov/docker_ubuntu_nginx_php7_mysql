service php7-fpm start; 
service mysql start;
nginx -g "daemon off;";
#mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
#mysql -e "FLUSH PRIVILEGES"
bash