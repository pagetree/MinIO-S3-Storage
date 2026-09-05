FROM caddy:2-alpine

COPY --from=minio/minio:latest /usr/bin/minio /usr/bin/minio
COPY --from=minio/mc:latest /usr/bin/mc /usr/bin/mc

COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/start.sh
COPY init/init-bucket.sh /usr/local/bin/init-bucket.sh

RUN sed -i 's/\r$//' /usr/local/bin/start.sh /usr/local/bin/init-bucket.sh \
    && chmod +x /usr/local/bin/start.sh /usr/local/bin/init-bucket.sh /usr/bin/minio /usr/bin/mc

ENV MINIO_API_PORT=10100 \
    MINIO_CONSOLE_PORT=10101 \
    BUCKET_NAME=bucket \
    RAILWAY_RUN_UID=0

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start.sh"]
