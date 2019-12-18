# pgbackup - pg_dump Postgres DB into S3 bucket

https://hub.docker.com/r/pressly/pgbackup/tags

## Usage

```
docker run -it -e DB=postgres://user@domain:5432/dbname -e PGPASSWORD=XXX -e BUCKET=my-bucket-name/subdir pressly/pgbackup:pg11awscli1.16.305
```

## Build

```
docker build -f Dockerfile -t pressly/pgbackup:pg11awscli1.16.305 $(mktemp -d)
```
