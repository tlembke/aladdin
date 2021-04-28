
dir=$(dirname $0)
cd $dir
bundle exec sidekiq -e production
