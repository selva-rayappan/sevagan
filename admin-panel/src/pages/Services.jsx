import { useState, useEffect } from 'react'
import { getServices, createService, updateService, deleteService } from '../services/api'

export default function Services() {
    const [services, setServices] = useState([])
    const [showModal, setShowModal] = useState(false)
    const [editingService, setEditingService] = useState(null)
    const [formData, setFormData] = useState({
        name: '',
        nameEn: '',
        nameTa: '',
        basePrice: '',
        minPrice: '',
        maxPrice: '',
        commissionPercent: '',
    })

    useEffect(() => {
        loadServices()
    }, [])

    const loadServices = async () => {
        try {
            const data = await getServices()
            setServices(data)
        } catch (error) {
            console.error('Error loading services:', error)
        }
    }

    const handleSubmit = async (e) => {
        e.preventDefault()
        try {
            if (editingService) {
                await updateService(editingService.id, formData)
            } else {
                await createService(formData)
            }
            setShowModal(false)
            setEditingService(null)
            setFormData({
                name: '',
                nameEn: '',
                nameTa: '',
                basePrice: '',
                minPrice: '',
                maxPrice: '',
                commissionPercent: '',
            })
            loadServices()
        } catch (error) {
            console.error('Error saving service:', error)
        }
    }

    const handleEdit = (service) => {
        setEditingService(service)
        setFormData(service)
        setShowModal(true)
    }

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this service?')) {
            try {
                await deleteService(id)
                loadServices()
            } catch (error) {
                console.error('Error deleting service:', error)
            }
        }
    }

    return (
        <div>
            <div className="flex justify-between items-center mb-8">
                <h1 className="text-3xl font-bold text-gray-900">Service Categories</h1>
                <button
                    onClick={() => setShowModal(true)}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                    Add Service
                </button>
            </div>

            <div className="bg-white rounded-lg shadow overflow-hidden">
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name (EN)</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name (TA)</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Base Price</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Price Range</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Commission %</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {services.map((service) => (
                            <tr key={service.id}>
                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                    {service.nameEn}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    {service.nameTa}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    ₹{service.basePrice}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    ₹{service.minPrice} - ₹{service.maxPrice}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    {service.commissionPercent}%
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                                    <button
                                        onClick={() => handleEdit(service)}
                                        className="text-blue-600 hover:text-blue-900"
                                    >
                                        Edit
                                    </button>
                                    <button
                                        onClick={() => handleDelete(service.id)}
                                        className="text-red-600 hover:text-red-900"
                                    >
                                        Delete
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {/* Modal would go here - simplified for brevity */}
        </div>
    )
}
