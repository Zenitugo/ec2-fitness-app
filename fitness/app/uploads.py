from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.models import Workout, User
from app.schemas.schemas import WorkoutResponse
from app.services.auth import get_current_user
from app.services.s3 import upload_file_to_s3, delete_file_from_s3

router = APIRouter()

ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/jpg", "image/gif"]
ALLOWED_VIDEO_TYPES = ["video/mp4", "video/quicktime", "video/x-msvideo"]
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB


@router.post("/workout/{workout_id}/media", response_model=WorkoutResponse)
async def upload_workout_media(
    workout_id: int,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload an image or video for a workout to S3"""
    workout = db.query(Workout).filter(
        Workout.id == workout_id,
        Workout.user_id == current_user.id
    ).first()

    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")

    allowed_types = ALLOWED_IMAGE_TYPES + ALLOWED_VIDEO_TYPES
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Only images (JPEG, PNG) and videos (MP4, MOV) are allowed"
        )

    content = await file.read()

    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File size must be under 50MB")

    # Delete old media if exists
    if workout.media_url:
        delete_file_from_s3(workout.media_url)

    # Determine folder based on file type
    folder = "workout-videos" if file.content_type in ALLOWED_VIDEO_TYPES else "workout-images"

    url = upload_file_to_s3(content, file.filename, file.content_type, folder)

    workout.media_url = url
    db.commit()
    db.refresh(workout)
    return workout


@router.delete("/workout/{workout_id}/media", response_model=WorkoutResponse)
def delete_workout_media(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete workout media from S3"""
    workout = db.query(Workout).filter(
        Workout.id == workout_id,
        Workout.user_id == current_user.id
    ).first()

    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")

    if not workout.media_url:
        raise HTTPException(status_code=400, detail="No media found for this workout")

    delete_file_from_s3(workout.media_url)
    workout.media_url = None
    db.commit()
    db.refresh(workout)
    return workout