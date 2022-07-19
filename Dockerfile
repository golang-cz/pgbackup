FROM python:3-alpine3.16

RUN pip install --no-cache-dir awscli==1.25.32

RUN apk add --no-cache --update postgresql-client>14

RUN aws --version && psql --version

WORKDIR /aws

# Required ENV vars:
# DB .......... connection string
# PGPASSWORD .. password
# BUCKET ...... S3 bucket name [/subdir]
#
# You might need to enable server side encryption with
#   aws s3 cp --sse aws:kms
# by overriding the command.

CMD sh -c 'pg_dump -C -w --format=c --blobs $DB | aws s3 cp - s3://$BUCKET/$(basename $DB)-$(TZ=UTC date +%F-%H-%M-%S).sql.gz'
