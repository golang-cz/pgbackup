# pgbackup - pg_dump Postgres DB into S3 bucket

## Usage

```
docker run -it -e DB=postgres://user@domain:5432/dbname -e PGPASSWORD=XXX -e BUCKET=my-bucket-name/subdir pressly/pgbackup:alpine3.10
```

## Build

```
docker build -f Dockerfile.pgbackup -t pressly/pgbackup:alpine3.10 $(mktemp -d)
```
