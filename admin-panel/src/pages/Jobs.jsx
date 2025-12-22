import { useState, useEffect } from 'react'
import { getJobs } from '../services/api'

const STATUS_COLORS = {
    REQUESTED: 'bg-yellow-100 text-yellow-800',
    TECHNICIAN_ASSIGNED: 'bg-blue-100 text-blue-800',
    JOB_STARTED: 'bg-purple-100 text-purple-800',
    JOB_COMPLETED: 'bg-green-100 text-green-800',
    COMPLETED: 'bg-green-100 text-green-800',
    CANCELLED: 'bg-red-100 text-red-800',
}

export default function Jobs() {
    const [jobs, setJobs] = useState([])
    const [filter, setFilter] = useState('ALL')
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        loadJobs()
    }, [filter])

    const loadJobs = async () => {
        setLoading(true)
        try {
            const data = await getJobs()
            setJobs(data)
        } catch (error) {
            console.error('Error loading jobs:', error)
        } finally {
            setLoading(false)
        }
    }

    const filteredJobs = filter === 'ALL'
        ? jobs
        : jobs.filter(job => job.status === filter)

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleString('en-IN', {
            dateStyle: 'medium',
            timeStyle: 'short'
        })
    }

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold text-gray-900">Jobs</h1>
                <div className="flex gap-4 items-center">
                    <select
                        value={filter}
                        onChange={(e) => setFilter(e.target.value)}
                        className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                        <option value="ALL">All Status</option>
                        <option value="REQUESTED">Requested</option>
                        <option value="TECHNICIAN_ASSIGNED">Assigned</option>
                        <option value="JOB_STARTED">In Progress</option>
                        <option value="JOB_COMPLETED">Completed</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                    <button
                        onClick={loadJobs}
                        className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                    >
                        Refresh
                    </button>
                </div>
            </div>

            {loading ? (
                <div className="flex justify-center items-center h-64">
                    <div className="text-gray-600">Loading jobs...</div>
                </div>
            ) : filteredJobs.length === 0 ? (
                <div className="bg-white rounded-lg shadow p-12 text-center">
                    <p className="text-gray-600 text-lg">No jobs found</p>
                </div>
            ) : (
                <div className="bg-white rounded-lg shadow overflow-hidden">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">ID</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Service</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Technician</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Location</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {filteredJobs.map((job) => (
                                <tr key={job.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-500">
                                        {job.id.substring(0, 8)}...
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        {job.customer?.name || 'N/A'}
                                        <div className="text-xs text-gray-500">{job.customer?.phone}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        {job.serviceCategory?.name || 'N/A'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        {job.technician?.name || 'Unassigned'}
                                        {job.technician && (
                                            <div className="text-xs text-gray-500">{job.technician.user?.phone}</div>
                                        )}
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500 max-w-xs truncate">
                                        {job.locationAddress || 'N/A'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                        ₹{job.finalPrice || job.estimatedPrice}
                                        {job.finalPrice && job.finalPrice !== job.estimatedPrice && (
                                            <div className="text-xs text-gray-500">Est: ₹{job.estimatedPrice}</div>
                                        )}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${STATUS_COLORS[job.status] || 'bg-gray-100 text-gray-800'}`}>
                                            {job.status.replace(/_/g, ' ')}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {formatDate(job.createdAt)}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            <div className="mt-4 text-sm text-gray-600">
                Showing {filteredJobs.length} of {jobs.length} jobs
            </div>
        </div>
    )
}
