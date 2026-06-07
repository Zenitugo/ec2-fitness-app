from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import users, workouts, uploads
from app.database import engine, Base

# Create all tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="FitTrack API",
    description="Fitness tracking application API",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(workouts.router, prefix="/workouts", tags=["Workouts"])
app.include_router(uploads.router, prefix="/uploads", tags=["Uploads"])


@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "fittrack-api"}