web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
resque: env TERM_CHILD=1 COUNT=2 QUEUE=relation,email,stats,* bundle exec rake resque:work
