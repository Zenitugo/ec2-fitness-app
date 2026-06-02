import { Link, useLocation } from "react-router-dom"
import { useAuth } from "../context/AuthContext"

export default function Navbar() {
  const { user, logout } = useAuth()
  const location = useLocation()

  const isActive = (path) => location.pathname === path
    ? "text-blue-600 font-medium"
    : "text-gray-600 hover:text-blue-600"

  return (
    <nav className="bg-white shadow-sm border-b">
      <div className="max-w-4xl mx-auto px-4 py-3 flex justify-between items-center">
        <Link to="/" className="text-xl font-bold text-blue-600">
          FitTrack 💪
        </Link>

        <div className="flex items-center space-x-6">
          <Link to="/" className={`text-sm ${isActive("/")}`}>Dashboard</Link>
          <Link to="/workouts" className={`text-sm ${isActive("/workouts")}`}>Workouts</Link>
          <Link to="/profile" className={`text-sm ${isActive("/profile")}`}>Profile</Link>
          <button
            onClick={logout}
            className="text-sm text-red-400 hover:text-red-600"
          >
            Logout
          </button>
        </div>
      </div>
    </nav>
  )
}
