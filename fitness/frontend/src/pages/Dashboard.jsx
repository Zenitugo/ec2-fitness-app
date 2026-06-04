import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import api from "../services/api"
import { useAuth } from "../context/AuthContext"

export default function Dashboard() {
  const { user } = useAuth()
  const [workouts, setWorkouts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    api.get("/workouts/")
      .then(res => setWorkouts(res.data))
      .finally(() => setLoading(false))
  }, [])

  const totalMinutes = workouts.reduce((sum, w) => sum + w.duration_minutes, 0)
  const totalCalories = workouts.reduce((sum, w) => sum + (w.calories_burned || 0), 0)

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-2">
        Welcome back, {user?.name}! 👋
      </h1>
      <p className="text-gray-500 mb-8">Here is your fitness summary</p>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-8">
        <div className="bg-white rounded-lg shadow p-6 text-center">
          <p className="text-3xl font-bold text-blue-600">{workouts.length}</p>
          <p className="text-gray-500 text-sm mt-1">Total Workouts</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6 text-center">
          <p className="text-3xl font-bold text-green-600">{totalMinutes}</p>
          <p className="text-gray-500 text-sm mt-1">Minutes Trained</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6 text-center">
          <p className="text-3xl font-bold text-orange-600">{Math.round(totalCalories)}</p>
          <p className="text-gray-500 text-sm mt-1">Calories Burned</p>
        </div>
      </div>

      {/* Recent Workouts */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold text-gray-800">Recent Workouts</h2>
          <Link to="/workouts" className="text-blue-600 text-sm hover:underline">
            View all
          </Link>
        </div>

        {loading ? (
          <p className="text-gray-400 text-center py-4">Loading...</p>
        ) : workouts.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-gray-400 mb-4">No workouts yet</p>
            <Link
              to="/workouts"
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              Add your first workout
            </Link>
          </div>
        ) : (
          <div className="space-y-3">
            {workouts.slice(0, 5).map(workout => (
              <div key={workout.id} className="flex items-center justify-between py-3 border-b last:border-0">
                <div>
                  <p className="font-medium text-gray-800">{workout.title}</p>
                  <p className="text-sm text-gray-500">{workout.category} • {workout.duration_minutes} mins</p>
                </div>
                {workout.calories_burned && (
                  <span className="text-sm text-orange-500 font-medium">
                    {workout.calories_burned} kcal
                  </span>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

