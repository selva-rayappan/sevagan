import { Link, useLocation } from 'react-router-dom'
import { HomeIcon, UserGroupIcon, WrenchScrewdriverIcon, BriefcaseIcon, CreditCardIcon, ArrowRightOnRectangleIcon } from '@heroicons/react/24/outline'

const navigation = [
    { name: 'Dashboard', href: '/', icon: HomeIcon },
    { name: 'Technicians', href: '/technicians', icon: UserGroupIcon },
    { name: 'Services', href: '/services', icon: WrenchScrewdriverIcon },
    { name: 'Jobs', href: '/jobs', icon: BriefcaseIcon },
    { name: 'Payments', href: '/payments', icon: CreditCardIcon },
]

export default function Layout({ children, onLogout }) {
    const location = useLocation()

    return (
        <div className="min-h-screen bg-gray-100">
            {/* Sidebar */}
            <div className="fixed inset-y-0 left-0 w-60 bg-white shadow-lg">
                <div className="flex flex-col h-full">
                    <div className="flex items-center justify-center h-16 border-b">
                        <h1 className="text-xl font-bold text-gray-900">Sevagan Admin</h1>
                    </div>

                    <nav className="flex-1 px-4 py-6 space-y-2">
                        {navigation.map((item) => {
                            const isActive = location.pathname === item.href
                            return (
                                <Link
                                    key={item.name}
                                    to={item.href}
                                    className={`flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors ${isActive
                                            ? 'bg-blue-50 text-blue-600'
                                            : 'text-gray-700 hover:bg-gray-50'
                                        }`}
                                >
                                    <item.icon className="w-5 h-5 mr-3 flex-shrink-0" style={{ width: '20px', height: '20px', minWidth: '20px', minHeight: '20px' }} />
                                    {item.name}
                                </Link>
                            )
                        })}
                    </nav>

                    <div className="p-4 border-t">
                        <button
                            onClick={onLogout}
                            className="flex items-center w-full px-4 py-3 text-sm font-medium text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                        >
                            <ArrowRightOnRectangleIcon className="w-5 h-5 mr-3 flex-shrink-0" />
                            Logout
                        </button>
                    </div>
                </div>
            </div>

            {/* Main content */}
            <div className="ml-60 p-8 min-h-screen w-full">
                {children}
            </div>
        </div>
    )
}
