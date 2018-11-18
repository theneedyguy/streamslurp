#!/bin/bash
docker build . -t ckevi/streamslurp:latest
docker tag ckevi/streamslurp:latest ckevi/streamslurp:1.0
docker push ckevi/streamslurp:latest
docker push ckevi/streamslurp:1.0
