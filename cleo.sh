#!/bin/bash

# language
# export LANGUAGE=pt_BR

# nome do computador
HOST=`hostname`

# executa a aplicação (-OO)
/usr/bin/env python3 cleo.py >> cleo.$HOST.log 2>&1