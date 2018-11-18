FROM alpine:3.8
RUN mkdir -p /opt/streamslurp/vods/

COPY ./app.sh /opt/streamslurp/
COPY ./requirements.txt /opt/streamslurp/
COPY ./fix-permissions /usr/bin/fix-permissions

RUN apk add jq
RUN apk add curl

# Python specific tasks
RUN apk add build-base
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache
RUN pip install -r /opt/streamslurp/requirements.txt

# Install bash
RUN apk add bash

RUN /usr/bin/fix-permissions /opt/streamslurp/ && /usr/bin/fix-permissions /opt/streamslurp/vods/
WORKDIR /opt/streamslurp

VOLUME ["/opt/streamslurp/vods"]

ENTRYPOINT ["bash","-c", "while true; do './app.sh'; sleep 3600; done"]
