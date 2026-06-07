from dotenv import load_dotenv
load_dotenv()
import os
import boto3
import json
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker



def get_db_credentials():
    """Fetch database credentials from AWS Secrets Manager"""
    secret_arn = os.getenv("DB_SECRET_ARN")

    if secret_arn:
        client = boto3.client("secretsmanager", region_name=os.getenv("AWS_REGION", "us-east-1"))
        response = client.get_secret_value(SecretId=secret_arn)
        secret = json.loads(response["SecretString"])
        return secret.get("username"), secret.get("password")

    # Fallback for local development
    return os.getenv("DB_USER", "postgres"), os.getenv("DB_PASSWORD", "password")


def get_database_url():
    username, password = get_db_credentials()
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    name = os.getenv("DB_NAME")
    return f"postgresql://{username}:{password}@{host}:{port}/{name}"


DATABASE_URL = get_database_url()

ssl_mode = os.getenv("DB_SSL_MODE")

engine = create_engine(
    DATABASE_URL,
    connect_args={"sslmode": "require"} if ssl_mode else {}

)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Dependency for database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()