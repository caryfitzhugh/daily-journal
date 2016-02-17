#!/bin/bash

export DAILY_JOURNAL_PG_PORT=${DAILY_JOURNAL_PG_PORT-25011}
export DAILY_JOURNAL_ENV=${DAILY_JOURNAL_ENV-development}
export DAILY_JOURNAL_UNIQUE_ID="pg-$DAILY_JOURNAL_PG_PORT"
export AWS_LOCAL_FILENAME=".aws-docker-containers.$DAILY_JOURNAL_ENV.$DAILY_JOURNAL_UNIQUE_ID"

wait_for_processes() {
  echo "Waiting..."
  echo "waiting for things to spin up..."
  until nc -z localhost $DAILY_JOURNAL_PG_PORT </dev/null; do sleep 0.1; done
  echo "Ports are open!"
}

start_aws_local() {
  echo "Starting PG at $DAILY_JOURNAL_PG_ENDPOINT"
  PG_GUID=`sudo docker run -d -e POSTGRES_PASSWORD=daily-journal -e POSTGRES_USER=daily-journal -e POSTGRES_DB=daily-journal -p $DAILY_JOURNAL_PG_PORT:5432 postgres`

  echo "$PG_GUID" > $AWS_LOCAL_FILENAME

  echo "Started docker local AWS $PG_GUID "
  wait_for_processes

  echo "Running migrate with profile: $DAILY_JOURNAL_ENV"
  RAILS_ENV=$DAILY_JOURNAL_ENV rake db:migrate
}

stop_aws_local() {
  sudo docker rm -f `cat $AWS_LOCAL_FILENAME `
}

if [ "$1" == "start" ]; then
  echo "Starting AWS Local..."
  stop_aws_local
  start_aws_local
elif [ "$1" == "stop" ]; then
  echo "Stopping AWS Local..."
  stop_aws_local
else
  echo "Need command [start, stop]"
fi
