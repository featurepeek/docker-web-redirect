#!/bin/bash
if [ -z "$REDIRECT_TARGET" ]; then
	echo "Redirect target variable not set (REDIRECT_TARGET)"
	exit 1
else
	# Add http if not set
	if ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
		REDIRECT_TARGET="http://$REDIRECT_TARGET"
	fi

	# Add trailing slash
	if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
		REDIRECT_TARGET="$REDIRECT_TARGET/"
	fi

	echo "Redirecting HTTP requests to ${REDIRECT_TARGET}..."
fi

cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;

	if (\$http_x_forwarded_proto = "http") {
     	return 301 https://\$host\$request_uri;
 	}

	location = /health {
        return 200 'Healthy www redirect';
	}

	location / {
		rewrite ^/(.*)\$ $REDIRECT_TARGET\$1 permanent;
	}
}
EOF

exec nginx -g "daemon off;"
