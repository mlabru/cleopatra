#!/bin/bash

# language
# export LANGUAGE=pt_BR

# cleo directory
CLEO=~/clsim/cleo

# nome do computador
HOST=`hostname`

# get today's date
TDATE=`date '+%Y-%m-%d_%H-%M-%S'`

# home directory exists ?
if [ -d ${CLEO} ]; then
    # set home dir
    cd ${CLEO}
fi

# rabbitMQ container not loaded ?
if ! [ "$( docker container inspect -f '{{.State.Running}}' rabbitmq )" == "true" ]; then
    # upload rabbitmq
    docker-compose up -d &
fi

# ckeck if another instance is running
DI_PID_WORKER=`ps ax | grep -w python3 | grep -w worker.py | awk '{ print $1 }'`

if [ ! -z "$DI_PID_WORKER" ]; then
    # log warning
    echo "[`date`]: process worker is already running. Restarting..."
    # kill process
    kill -9 $DI_PID_WORKER
fi

# executa o worker (message queue consumer)
python3 worker.py > logs/worker.$HOST.$TDATE.log 2>&1 &

# ckeck if another instance is running
DI_PID_CLEO=`ps ax | grep -w streamlit | grep -w cleo.py | awk '{ print $1 }'`

if [ ! -z "$DI_PID_CLEO" ]; then
    # log warning
    echo "[`date`]: process cleo is already running. Restarting..."
    # kill process
    kill -9 $DI_PID_CLEO
fi

# executa a aplicação (-OO)
streamlit run cleo.py > logs/cleo.$HOST.$TDATE.log 2>&1 &

# < the end >----------------------------------------------------------------------------------
