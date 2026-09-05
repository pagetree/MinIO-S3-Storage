import { defineRailway, github, project, service, volume } from "railway/iac";

export default defineRailway(() => {
  const data = volume("minio-data");

  const minio = service("MinIO", {
    source: github("pagetree/MinIO-S3-Storage"),
    healthcheck: "/minio/health/live",
    healthcheckTimeout: 120,
    volumeMounts: {
      "/data": data,
    },
    env: {
      MINIO_SERVER_URL: "https://${{RAILWAY_PUBLIC_DOMAIN}}",
      MINIO_BROWSER_REDIRECT_URL: "https://${{RAILWAY_PUBLIC_DOMAIN}}",
      BUCKET_NAME: "bucket",
      MINIO_API_PORT: "10100",
      MINIO_CONSOLE_PORT: "10101",
      RAILWAY_RUN_UID: "0",
    },
  });

  return project("S3 Storage", {
    resources: [minio, data],
  });
});
