from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


# ─── User Schemas ────────────────────────────────────────────

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    profile_photo_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    name: Optional[str] = None
    profile_photo_url: Optional[str] = None


# ─── Token Schemas ───────────────────────────────────────────

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    email: Optional[str] = None


# ─── Workout Schemas ─────────────────────────────────────────

class WorkoutCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    duration_minutes: int
    calories_burned: Optional[float] = None


class WorkoutResponse(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str] = None
    category: str
    duration_minutes: int
    calories_burned: Optional[float] = None
    media_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class WorkoutUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    duration_minutes: Optional[int] = None
    calories_burned: Optional[float] = None