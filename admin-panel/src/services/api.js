import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api'

const api = axios.create({
    baseURL: API_URL,
})

// Add auth token to requests
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('adminToken')
    if (token) {
        config.headers.Authorization = `Bearer ${token}`
    }
    return config
})

// Auth
export const login = async (email, password) => {
    const response = await api.post('/auth/admin/login', { email, password })
    return response.data
}

// Technicians
export const getTechnicians = async (status) => {
    const params = status ? { status } : {}
    const response = await api.get('/admin/technicians', { params })
    return response.data
}

export const approveTechnician = async (id) => {
    const response = await api.post(`/admin/technicians/${id}/approve`)
    return response.data
}

export const rejectTechnician = async (id) => {
    const response = await api.post(`/admin/technicians/${id}/reject`)
    return response.data
}

export const toggleTechnicianStatus = async (id, isActive) => {
    const response = await api.put(`/admin/technicians/${id}/toggle-status`, { isActive })
    return response.data
}

// Services
export const getServices = async () => {
    const response = await api.get('/admin/services')
    return response.data
}

export const createService = async (data) => {
    const response = await api.post('/admin/services', data)
    return response.data
}

export const updateService = async (id, data) => {
    const response = await api.put(`/admin/services/${id}`, data)
    return response.data
}

export const deleteService = async (id) => {
    const response = await api.delete(`/admin/services/${id}`)
    return response.data
}

// Jobs
export const getJobs = async (filters) => {
    const response = await api.get('/jobs', { params: filters })
    return response.data
}

export const reassignJob = async (id, technicianId) => {
    const response = await api.post(`/admin/jobs/${id}/reassign`, { technicianId })
    return response.data
}

// Payments
export const getPayments = async () => {
    const response = await api.get('/admin/payments')
    return response.data
}

// Analytics
export const getAnalytics = async (startDate, endDate) => {
    const params = {}
    if (startDate) params.startDate = startDate
    if (endDate) params.endDate = endDate
    const response = await api.get('/admin/analytics', { params })
    return response.data
}

export default api
