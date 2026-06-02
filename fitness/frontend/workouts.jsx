import { useState, useEffect } from "react"
import api from "../services/api"

const CATEGORIES = ["Strength", "Cardio", "Yoga", "HIIT", "Flexibility", "Other"]

export default function Workouts() {
  const [workouts, setWorkouts] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [uploading, setUploading] = useState(null)
  const [form, setForm] = useState({
    title: "", description: "", category: "Strength",
    duration_minutes: "", calories_burned: ""
  })

  useEffect(() => {
    fetchWorkouts()
  }, [])

  const fetchWorkouts = async () => {
    const res = await api.get("/workouts/")
    setWorkouts(res.data)
    setLoading(false)
  }

  const handleCreate = async (e) => {
    e.preventDefault()
    await api.post("/workouts/", {
      ...form,
      duration_minutes: parseInt(form.duration_minutes),
      calories_burned: form.calories_burned ? parseFloat(form.calories_burned) : null
    })
    setForm({ title: "", description: "", category: "Strength", duration_minutes: "", calories_burned: "" })
    setShowForm(false)
    fetchWorkouts()
  }

  const handleDelete = async (id) => {
    if (!confirm("Delete this workout?")) return
    await api.delete(`/workouts/${id}`)
    fetchWorkouts()
  }

  const handleMediaUpload = async (workoutId, file) => {
    setUploading(workoutId)
    const formData = new FormData()
    formData.append("file", file)
    await api.post(`/uploads/workout/${workoutId}/media`, formData, {
      headers: { "Content-Type": "multipart/form-data" }
    })
    setUploading(null)
    fetchWorkouts()
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">My Workouts</h1>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          {showForm ? "Cancel" : "+ Add Workout"}
        </button>
      </div>

      {/* Add Workout Form */}
      {showForm && (
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">New Workout</h2>
          <form onSubmit={handleCreate} className="space-y-4">
            <input
              type="text"
              placeholder="Workout title"
              value={form.title}
              onChange={e => setForm({ ...form, title: e.target.value })}
              className="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
            <textarea
              placeholder="Description (optional)"
              value={form.description}
              onChange={e => setForm({ ...form, description: e.target.value })}
              className="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={3}
            />
            <div className="grid grid-cols-3 gap-4">
              <select
                value={form.category}
                onChange={e => setForm({ ...form, category: e.target.value })}
                className="border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {CATEGORIES.map(c => <option key={c}>{c}</option>)}
              </select>
              <input
                type="number"
                placeholder="Duration (mins)"
                value={form.duration_minutes}
                onChange={e => setForm({ ...form, duration_minutes: e.target.value })}
                className="border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
              <input
                type="number"
                placeholder="Calories (optional)"
                value={form.calories_burned}
                onChange={e => setForm({ ...form, calories_burned: e.target.value })}
                className="border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <button
              type="submit"
              className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
            >
              Save Workout
            </button>
          </form>
        </div>
      )}

      {/* Workout List */}
      {loading ? (
        <p className="text-gray-400 text-center py-8">Loading workouts...</p>
      ) : workouts.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <p className="text-gray-400 text-lg">No workouts yet</p>
          <p className="text-gray-300 text-sm mt-2">Add your first workout above</p>
        </div>
      ) : (
        <div className="space-y-4">
          {workouts.map(workout => (
            <div key={workout.id} className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-semibold text-gray-800 text-lg">{workout.title}</h3>
                  <p className="text-sm text-gray-500 mt-1">
                    {workout.category} • {workout.duration_minutes} mins
                    {workout.calories_burned && ` • ${workout.calories_burned} kcal`}
                  </p>
                  {workout.description && (
                    <p className="text-gray-600 text-sm mt-2">{workout.description}</p>
                  )}
                </div>
                <button
                  onClick={() => handleDelete(workout.id)}
                  className="text-red-400 hover:text-red-600 text-sm"
                >
                  Delete
                </button>
              </div>

              {/* Media */}
              {workout.media_url && (
                <div className="mt-4">
                  {workout.media_url.includes(".mp4") || workout.media_url.includes(".mov") ? (
                    <video src={workout.media_url} controls className="w-full rounded max-h-48 object-cover" />
                  ) : (
                    <img src={workout.media_url} alt="Workout" className="w-full rounded max-h-48 object-cover" />
                  )}
                </div>
              )}

              {/* Upload Media */}
              <div className="mt-4">
                <label className="cursor-pointer text-sm text-blue-600 hover:underline">
                  {uploading === workout.id ? "Uploading..." : workout.media_url ? "Replace media" : "Upload image/video"}
                  <input
                    type="file"
                    accept="image/*,video/*"
                    className="hidden"
                    onChange={e => handleMediaUpload(workout.id, e.target.files[0])}
                    disabled={uploading === workout.id}
                  />
                </label>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
