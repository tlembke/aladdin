#!/bin/bash
SERVICE=sidekiq
if P=$(pgrep $SERVICE)
then
    echo "$SERVICE is running, PID is $P"
else


	cmd=start
	PROJECT_DIR="/Users/tlembke/Projects/aladdin"
	PIDFILE=$PROJECT_DIR/tmp/pids/sidekiq.pid
	cd $PROJECT_DIR


	LOGFILE=$PROJECT_DIR/log/sidekiq.log
	CONFILE=$PROJECT_DIR/config/sidekiq.yml
	echo "Starting sidekiq..."
	bundle exec sidekiq  -d -L $LOGFILE -P $PIDFILE  -C $CONFILE -e development

fi
exit 0
