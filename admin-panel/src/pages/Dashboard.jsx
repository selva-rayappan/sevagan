import { useState, useEffect } from 'react'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'
import { getAnalytics } from '../services/api'

export default function Dashboard() {
    const [analytics, setAnalytics] = useState(null)
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        loadAnalytics()
    }, [])

    const loadAnalytics = async () => {
        try {
            const data = await getAnalytics()
            setAnalytics(data)
        } catch (error) {
            console.error('Error loading analytics:', error)
        } finally {
            setLoading(false)
        }
    }

    if (loading) {
        return <div className="flex justify-center items-center h-64">Loading...</div>
    }

    const stats = [
        { name: 'Total Jobs', value: analytics?.totalJobs || 0, color: 'bg-blue-500' },
        { name: 'Completed Jobs', value: analytics?.completedJobs || 0, color: 'bg-green-500' },
        { name: 'Active Technicians', value: analytics?.activeTechnicians || 0, color: 'bg-purple-500' },
        { name: 'Revenue', value: `₹${analytics?.revenue?.toFixed(0) || 0}`, color: 'bg-yellow-500' },
    ]

    return (
        <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                {stats.map((stat) => (
                    <div key={stat.name} className="bg-white rounded-lg shadow p-6">
                        <div className={`w-12 h-12 ${stat.color} rounded-lg flex items-center justify-center mb-4`}>
                            <div className="w-6 h-6 bg-white rounded"></div>
                        </div>
                        <p className="text-sm text-gray-600">{stat.name}</p>
                        <p className="text-2xl font-bold text-gray-900 mt-1">{stat.value}</p>
                    </div>
                ))}
            </div>

            {/* Top Categories Chart */}
            <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-xl font-bold text-gray-900 mb-4">Top Service Categories</h2>
                <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={analytics?.topCategories || []}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="category" />
                        <YAxis />
                        <Tooltip />
                        <Bar dataKey="count" fill="#3b82f6" />
                    </BarChart>
                </ResponsiveContainer>
            </div>
        </div>
    )
}
