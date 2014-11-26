FROM     phusion/passenger-customizable
RUN      /build/ruby2.1.sh

# enable nginx
RUN      rm -f /etc/service/nginx/down
RUN      rm /etc/nginx/sites-enabled/default

# nginx config for RC-API
ADD      nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD      nginx-env.conf /etc/nginx/main.d/nginx-env.conf

# copy over rails app & install dependencies
COPY     . /home/app/webapp
WORKDIR  /home/app/webapp
RUN      chown -R app:app /home/app/webapp
RUN      sudo -u app bundle install --deployment
