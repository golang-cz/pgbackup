# pgbackup (pg_dump/pg_restore) Postgres DB into S3 bucket

https://github.com/golangcz/pgbackup/packages/214376/versions

# Docker usage

```
docker run -it -e DB=postgres://user@domain:5432/dbname -e PGPASSWORD=XXX -e BUCKET=my-bucket-name/subdir pressly/pgbackup:pg12awscli1.18.54
```

# Kubernetes usage

## Nightly cron job to backup Postgres DB to S3

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: pgbackup
spec:
  schedule: "0 6 * * 0-5" # Mon-Fri at 6am UTC
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          serviceAccountName: backups
          containers:
          - name: pgbackup
            image: pressly/pgbackup:pg12awscli1.18.54
            command:
              - sh
              - -c
              - pg_dump -C -w --format=c --blobs --no-owner --no-privileges --no-acl dbname | aws s3 cp --sse aws:kms - s3://$BUCKET/dbname-$(TZ=UTC date +%F-%H-%M-%S).sqlc
            env:
              - name: PGHOST
                value: your-db-connection-string
              - name: PGUSER
                value: your-user
              - name: PGPASSWORD
                value: your-password
              - name: BUCKET
                value: db-backups
```

## Single-use pod to import (restore) the latest DB backup from S3

```
apiVersion: v1
kind: Pod
metadata:
  name: pgrestore-import-latest-backup
spec:
  restartPolicy: Never
  serviceAccountName: backups
  containers:
    - name: pgrestore
      image: pressly/pgbackup:pg12awscli1.18.54
      command:
        - sh
        - -c
        - |
          db="$(aws s3api list-objects-v2 --bucket $BUCKET --prefix dbname --query 'reverse(sort_by(Contents, &LastModified))[:1].Key' --output=text)"
          echo "latest DB backup: $db"            
          aws s3 cp "s3://$BUCKET/$db" .
          psql -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'dbname' AND pid <> pg_backend_pid()"
          dropdb dbname
          createdb dbname
          pg_restore -j 8 -d dbname --no-owner --no-privileges --no-acl -n public "$db"
      env:
        - name: PGHOST
          value: your-db-connection-string
        - name: PGUSER
          value: your-user
        - name: PGPASSWORD
          value: your-password
        - name: BUCKET
          value: db-backups
```
