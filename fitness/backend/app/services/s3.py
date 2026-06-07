import os
import boto3
import uuid
import logging
from fastapi import HTTPException


S3_BUCKET = os.getenv("S3_BUCKET_NAME", "fittrack-media")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

s3_client = boto3.client("s3", region_name=AWS_REGION)


logger = logging.getLogger(__name__)


def upload_file_to_s3(file_content: bytes, filename: str, content_type: str, folder: str) -> str:
    """Upload a file to S3 and return the URL"""
    extension = filename.split(".")[-1]
    unique_filename = f"{folder}/{uuid.uuid4()}.{extension}"

    try:
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=unique_filename,
            Body=file_content,
            ContentType=content_type,
        )

        url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{unique_filename}"
        return url

    except Exception as e:
        logger.error(f"S3 upload failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to upload file: {str(e)}")


def delete_file_from_s3(file_url: str):
    """Delete a file from S3 using its URL"""
    try:
        key = file_url.split(f"{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/")[1]
        s3_client.delete_object(Bucket=S3_BUCKET, Key=key)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete file: {str(e)}")


def generate_presigned_url(file_url: str, expiry: int = 3600) -> str:
    """Generate a presigned URL for temporary access to a private S3 file"""
    try:
        key = file_url.split(f"{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/")[1]
        url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": S3_BUCKET, "Key": key},
            ExpiresIn=expiry
        )
        return url
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate URL: {str(e)}")