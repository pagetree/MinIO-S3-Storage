# S3 Storage — One Click

> Deploy your own S3-compatible object storage on Railway in one click.

[**Deploy on Railway**](https://railway.com/deploy/s3-storage-one-click)

**Deploy → Get S3 storage → Done.**

This template starts [MinIO](https://min.io) on Railway with everything already configured. You do not enter access keys, ports, bucket names, or endpoints.

## What you get

**MinIO**  
S3-compatible object storage from the official MinIO image.

**Persistent storage**  
Object data lives on a Railway volume at `/data`. Files survive redeploys, restarts, and image updates.

**Automatic credentials**  
A strong access key and secret key are generated when you deploy. Read them from the MinIO service Variables tab. They stay the same across redeploys unless you change them.

**Automatic `bucket`**  
A bucket named `bucket` is created during startup. If it already exists, startup still succeeds.

**Web console**  
Open the Railway public URL and log in with `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` from the MinIO Variables tab.

**S3-compatible API**  
Other Railway services connect on the private network:

```text
http://${{RAILWAY_PRIVATE_DOMAIN}}:9000
```

Region is `us-east-1`. Path style addressing works with the `bucket` bucket.

## Connect an app

```python
from minio import Minio

client = Minio(
    "minio.railway.internal:9000",
    access_key="MINIO_ROOT_USER",
    secret_key="MINIO_ROOT_PASSWORD",
    secure=False,
)

client.fput_object("bucket", "hello.txt", "hello.txt")
```

Use the values from the MinIO service Variables tab for `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`.

## Local test

```bash
docker compose up --build
```

S3 API: `http://localhost:9000`  
Console: `http://localhost:9001`  
User: `minioadmin`  
Password: `minioadmin`

## License

MIT. MinIO itself is licensed by MinIO, Inc.
