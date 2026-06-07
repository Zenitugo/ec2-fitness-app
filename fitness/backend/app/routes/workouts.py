from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from fastapi import UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.models import Workout, User
from app.schemas.schemas import WorkoutCreate, WorkoutResponse, WorkoutUpdate
from app.services.auth import get_current_user
from app.services.s3 import generate_presigned_url

router = APIRouter()


@router.post("/workout/{workout_id}/media")
async def upload_workout_media(workout_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    try:
        # Reset pointer
        file.file.seek(0)

        # Read file content
        content = await file.read()

        # Upload to S3
        url = upload_file_to_s3(
            file_content=content,
            filename=file.filename,
            content_type=file.content_type,
            folder=f"workouts/{workout_id}"
        )

        # Update DB with new URL
        raw_url = upload_file_to_s3(content, file.filename, file.content_type, folder)
        workout.media_url = raw_url
        db.commit()
        db.refresh(workout)

        return {
            "id": workout.id,
            "title": workout.title,
            "description": workout.description,
            "category": workout.category,
            "duration_minutes": workout.duration_minutes,
            "calories_burned": workout.calories_burned,
            "media_url": generate_presigned_url(workout.media_url),  # <-- presigned URL
            "created_at": workout.created_at,
            "user_id": workout.user_id
        }


    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.post("/", response_model=WorkoutResponse, status_code=status.HTTP_201_CREATED)
def create_workout(
    workout: WorkoutCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new workout"""
    new_workout = Workout(
        user_id=current_user.id,
        **workout.dict()
    )
    db.add(new_workout)
    db.commit()
    db.refresh(new_workout)
    return new_workout


@router.get("/", response_model=List[WorkoutResponse])
def get_workouts(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all workouts for the current user"""
    return db.query(Workout).filter(Workout.user_id == current_user.id).all()


@router.get("/{workout_id}", response_model=WorkoutResponse)
def get_workout(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific workout"""
    workout = db.query(Workout).filter(
        Workout.id == workout_id,
        Workout.user_id == current_user.id
    ).first()

    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")

    # Replace raw S3 URL with presigned URL
    presigned_url = (
        generate_presigned_url(workout.media_url)
        if workout.media_url else None
    )

    return {
        "id": workout.id,
        "user_id": workout.user_id,
        "title": workout.title,
        "description": workout.description,
        "category": workout.category,
        "duration_minutes": workout.duration_minutes,
        "calories_burned": workout.calories_burned,
        "media_url": presigned_url,
        "created_at": workout.created_at
    }


@router.put("/{workout_id}", response_model=WorkoutResponse)
def update_workout(
    workout_id: int,
    updates: WorkoutUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a workout"""
    workout = db.query(Workout).filter(
        Workout.id == workout_id,
        Workout.user_id == current_user.id
    ).first()

    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")

    for field, value in updates.dict(exclude_unset=True).items():
        setattr(workout, field, value)

    db.commit()
    db.refresh(workout)
    return workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_workout(
    workout_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a workout"""
    workout = db.query(Workout).filter(
        Workout.id == workout_id,
        Workout.user_id == current_user.id
    ).first()

    if not workout:
        raise HTTPException(status_code=404, detail="Workout not found")

    db.delete(workout)
    db.commit()


@router.get("/health")
def health():
    return {"status": "healthy", "service": "workouts"}