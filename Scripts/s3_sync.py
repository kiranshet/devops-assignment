import argparse
import logging
import os
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError


def configure_logging(log_file):
    os.makedirs(os.path.dirname(log_file) or ".", exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s UTC | %(levelname)s | %(message)s",
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ],
    )


def s3_object_exists(s3_client, bucket, key):
    try:
        s3_client.head_object(Bucket=bucket, Key=key)
        return True
    except ClientError as error:
        if error.response["Error"]["Code"] in ("404", "NoSuchKey"):
            return False
        raise


def sync_directory(local_dir, bucket, prefix="", kms_key_id=None):
    s3 = boto3.client("s3")

    scanned = 0
    uploaded = 0
    skipped = 0
    failed = 0

    for root, _, files in os.walk(local_dir):
        for filename in files:
            local_path = os.path.join(root, filename)
            relative_path = os.path.relpath(local_path, local_dir)
            s3_key = os.path.join(prefix, relative_path).replace("\\", "/")

            scanned += 1

            try:
                if s3_object_exists(s3, bucket, s3_key):
                    logging.info("SKIPPED | %s already exists", s3_key)
                    skipped += 1
                    continue

                extra_args = {}

                if kms_key_id:
                    extra_args = {
                        "ServerSideEncryption": "aws:kms",
                        "SSEKMSKeyId": kms_key_id,
                    }

                s3.upload_file(
                    local_path,
                    bucket,
                    s3_key,
                    ExtraArgs=extra_args,
                )

                logging.info("UPLOADED | %s", s3_key)
                uploaded += 1

            except Exception as error:
                logging.error("FAILED | %s | %s", s3_key, error)
                failed += 1

    logging.info("========== S3 SYNC SUMMARY ==========")
    logging.info("Total scanned : %d", scanned)
    logging.info("Uploaded      : %d", uploaded)
    logging.info("Skipped       : %d", skipped)
    logging.info("Failed        : %d", failed)
    logging.info("Completed     : %s", datetime.now(timezone.utc).isoformat())

    return failed


def main():
    parser = argparse.ArgumentParser(
        description="Sync a local directory to Amazon S3."
    )

    parser.add_argument(
        "--local-dir",
        required=True,
        help="Local directory to upload",
    )

    parser.add_argument(
        "--bucket",
        required=True,
        help="Destination S3 bucket",
    )

    parser.add_argument(
        "--prefix",
        default="",
        help="Optional S3 key prefix",
    )

    parser.add_argument(
        "--kms-key-id",
        default=None,
        help="Optional KMS key ID/ARN for SSE-KMS encryption",
    )

    parser.add_argument(
        "--log-file",
        default="logs/s3_sync.log",
        help="Timestamped log file",
    )

    args = parser.parse_args()

    configure_logging(args.log_file)

    failed = sync_directory(
        local_dir=args.local_dir,
        bucket=args.bucket,
        prefix=args.prefix,
        kms_key_id=args.kms_key_id,
    )

    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()