import { useState, useEffect } from 'react'
import { getTechnicians, approveTechnician, rejectTechnician, toggleTechnicianStatus } from '../services/api'

export default function Technicians() {
    const [technicians, setTechnicians] = useState([])
    const [filter, setFilter] = useState('ALL')
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        loadTechnicians()
    }, [filter])

    const loadTechnicians = async () => {
        setLoading(true)
        try {
            const status = filter === 'ALL' ? null : filter
            const data = await getTechnicians(status)
            setTechnicians(data)
        } catch (error) {
            console.error('Error loading technicians:', error)
        } finally {
            setLoading(false)
        }
    }

    const handleApprove = async (id) => {
        try {
            await approveTechnician(id)
            loadTechnicians()
        } catch (error) {
            console.error('Error approving technician:', error)
        }
    }

    const handleReject = async (id) => {
        try {
            await rejectTechnician(id)
            loadTechnicians()
        } catch (error) {
            console.error('Error rejecting technician:', error)
        }
    }

    const handleToggleStatus = async (id, isActive) => {
        try {
            await toggleTechnicianStatus(id, !isActive)
            loadTechnicians()
        } catch (error) {
            console.error('Error toggling status:', error)
        }
    }

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold text-gray-900">Technicians</h1>
                <select
                    value={filter}
                    onChange={(e) => setFilter(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                    <option value="ALL">All</option>
                    <option value="PENDING">Pending</option>
                    <option value="APPROVED">Approved</option>
                    <option value="REJECTED">Rejected</option>
                </select>
            </div>

            {loading ? (
                <div className="flex justify-center items-center h-64">Loading...</div>
            ) : (
                <div className="bg-white rounded-lg shadow overflow-hidden">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Phone</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Skills</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Rating</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {technicians.map((tech) => (
                                <tr key={tech.id}>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                        {tech.name}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {tech.user?.phone}
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500">
                                        {tech.skills?.join(', ')}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${tech.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
                                                tech.status === 'PENDING' ? 'bg-yellow-100 text-yellow-800' :
                                                    'bg-red-100 text-red-800'
                                            }`}>
                                            {tech.status}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {tech.rating?.toFixed(1)} ⭐
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                                        {tech.status === 'PENDING' && (
                                            <>
                                                <button
                                                    onClick={() => handleApprove(tech.id)}
                                                    className="text-green-600 hover:text-green-900"
                                                >
                                                    Approve
                                                </button>
                                                <button
                                                    onClick={() => handleReject(tech.id)}
                                                    className="text-red-600 hover:text-red-900"
                                                >
                                                    Reject
                                                </button>
                                            </>
                                        )}
                                        {tech.status === 'APPROVED' && (
                                            <button
                                                onClick={() => handleToggleStatus(tech.id, tech.user?.isActive)}
                                                className="text-blue-600 hover:text-blue-900"
                                            >
                                                {tech.user?.isActive ? 'Disable' : 'Enable'}
                                            </button>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    )
}
