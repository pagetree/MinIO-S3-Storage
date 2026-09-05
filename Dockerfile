FROM alpine:3.20

COPY --from=minio/minio:latest /usr/bin/minio /usr/bin/minio
COPY --from=minio/mc:latest /usr/bin/mc /usr/bin/mc

COPY start.sh /usr/local/bin/start.sh
COPY init/init-bucket.sh /usr/local/bin/init-bucket.sh

RUN sed -i 's/\r$//' /usr/local/bin/start.sh /usr/local/bin/init-bucket.sh \
    && chmod +x /usr/local/bin/start.sh /usr/local/bin/init-bucket.sh /usr/bin/minio /usr/bin/mc

ENV BUCKET_NAME=bucket \
    MINIO_CONSOLE_PORT=9001 \
    RAILWAY_RUN_UID=0

EXPOSE 9000 9001

ENTRYPOINT ["/usr/local/bin/start.sh"]
