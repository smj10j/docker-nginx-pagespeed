#!/bin/bash

service mysql restart
service php5-fpm restart
#service nginx restart
/usr/local/nginx/sbin/nginx

tail -f /var/log/nginx/*
