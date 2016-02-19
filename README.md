# Build

	docker build -t smj10j/nginx-pagespeed .

# Run

    ocker run --rm -ti --net host -v /Users/steve/nginx/etc/nginx:/etc/nginx -v /Users/steve/nginx/www:/usr/share/nginx/www -v /Users/steve/mysql:/var/lib/mysql -p 80:80 -p 443:443 smj10j/nginx-pagespeed

# Login to the machine

    docker exec -ti $(docker ps | tail -1 | awk '{print $1}') /bin/bash
