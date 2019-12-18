FROM python:alpine3.10

ARG CLI_VERSION=1.16.86
RUN pip install --no-cache-dir awscli==$CLI_VERSION

# RUN apk add --no-cache groff jq less && \

RUN apk add --no-cache --update postgresql-client

WORKDIR /aws

# Required ENV vars:
# DB .......... connection string
# PGPASSWORD .. password
# BUCKET ...... S3 bucket name [/subdir]

CMD sh -c 'pg_dump -C -w --format=c --blobs $DB | aws s3 cp - s3://$BUCKET/$(basename $DB)-$(TZ=UTC date +%F-%H-%M-%S).sql.gz'
