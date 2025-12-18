import { useState, useEffect } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Technicians from './pages/Technicians'
import Services from './pages/Services'
import Jobs from './pages/Jobs'
import Payments from './pages/Payments'
import Layout from './components/Layout'

function App() {
    const [isAuthenticated, setIsAuthenticated] = useState(false)

    useEffect(() => {
        const token = localStorage.getItem('adminToken')
        setIsAuthenticated(!!token)
    }, [])

    const handleLogin = () => {
        setIsAuthenticated(true)
    }

    const handleLogout = () => {
        localStorage.removeItem('adminToken')
        setIsAuthenticated(false)
    }

    if (!isAuthenticated) {
        return <Login onLogin={handleLogin} />
    }

    return (
        <Layout onLogout={handleLogout}>
            <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/technicians" element={<Technicians />} />
                <Route path="/services" element={<Services />} />
                <Route path="/jobs" element={<Jobs />} />
                <Route path="/payments" element={<Payments />} />
                <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
        </Layout>
    )
}

export default App
