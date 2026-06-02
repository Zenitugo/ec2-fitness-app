import { useState } from "react"
import api from "../services/api"
import { useAuth } from "../context/AuthContext"

export default function Profile() {
  const { user, setUser } = useAuth()
  const [name, setName] = useState(user?.name || "")
  const [uploading, setUploading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState("")

  const handleUpdateName = async (e) => {
    e.preventDefault()
    setSaving(true)
    const res = await api.put("/users/me", { name })
    setUser(res.data)
    setMessage("Profile updated successfully")
    setSaving(false)
    setTimeout(() => setMessage(""), 3000)
  }

  const handlePhotoUpload = async (e) => {
    const file = e.target.files[0]
    if (!file) return

    setUploading(true)
    const formData = new FormData()
    formData.append("file", file)

    const res = await api.post("/users/me/photo", formData, {
      headers: { "Content-Type": "multipart/form-data" }
    })
    setUser(res.data)
    setUploading(false)
    setMessage("Photo updated successfully")
    setTimeout(() => setMessage(""), 3000)
  }

  return (
    <div className="max-w-2xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-gray-800 mb-6">My Profile</h1>

      {message && (
        <div className="bg-green-50 text-green-600 p-3 rounded mb-4 text-sm">{message}</div>
      )}

      <div className="bg-white rounded-lg shadow p-6 space-y-6">

        {/* Profile Photo */}
        <div className="flex items-center space-x-6">
          <div className="w-24 h-24 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center">
            {user?.profile_photo_url ? (
              <img src={user.profile_photo_url} alt="Profile" className="w-full h-full object-cover" />
            ) : (
              <span className="text-3xl text-gray-400">👤</span>
            )}
          </div>
          <div>
            <p className="font-medium text-gray-800">{user?.name}</p>
            <p className="text-sm text-gray-500 mb-2">{user?.email}</p>
            <label className="cursor-pointer text-sm text-blue-600 hover:underline">
              {uploading ? "Uploading..." : "Change photo"}
              <input
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handlePhotoUpload}
                disabled={uploading}
              />
            </label>
          </div>
        </div>

        {/* Update Name */}
        <form onSubmit={handleUpdateName} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
            <input
              type="text"
              value={name}
              onChange={e => setName(e.target.value)}
              className="w-full border rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              value={user?.email}
              className="w-full border rounded px-3 py-2 bg-gray-50 text-gray-400 cursor-not-allowed"
              disabled
            />
            <p className="text-xs text-gray-400 mt-1">Email cannot be changed</p>
          </div>
          <button
            type="submit"
            disabled={saving}
            className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {saving ? "Saving..." : "Save Changes"}
          </button>
        </form>

        {/* Account Info */}
        <div className="border-t pt-4">
          <p className="text-sm text-gray-500">
            Member since: {new Date(user?.created_at).toLocaleDateString()}
          </p>
        </div>
      </div>
    </div>
  )
}
