#web: bin/start-stunnel bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
#worker: bin/start-stunnel bundle exec sidekiq -C config/sidekiq.yml
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -C config/sidekiq.yml
