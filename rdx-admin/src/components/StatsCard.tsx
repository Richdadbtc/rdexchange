import { ArrowDownIcon, ArrowUpIcon } from '@heroicons/react/20/solid'

interface StatsCardProps {
  title: string
  value: string
  icon: React.ComponentType<React.SVGProps<SVGSVGElement>>
  change: string
  changeType: 'increase' | 'decrease'
}

function classNames(...classes: string[]) {
  return classes.filter(Boolean).join(' ')
}

export default function StatsCard({ title, value, icon: Icon, change, changeType }: StatsCardProps) {
  return (
    <div className="overflow-hidden rounded-lg bg-gray-800 shadow">
      <div className="p-5">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <Icon className="h-6 w-6 text-gray-400" aria-hidden="true" />
          </div>
          <div className="ml-5 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-400 truncate">{title}</dt>
              <dd>
                <div className="text-lg font-medium text-white">{value}</div>
              </dd>
            </dl>
          </div>
        </div>
      </div>
      <div className="bg-gray-700 px-5 py-3">
        <div className="text-sm">
          <div className="flex items-center">
            {changeType === 'increase' ? (
              <ArrowUpIcon className="h-4 w-4 text-green-500" />
            ) : (
              <ArrowDownIcon className="h-4 w-4 text-red-500" />
            )}
            <span
              className={classNames(
                changeType === 'increase' ? 'text-green-500' : 'text-red-500',
                'ml-1 font-medium'
              )}
            >
              {change}
            </span>
            <span className="ml-1 text-gray-400">from last month</span>
          </div>
        </div>
      </div>
    </div>
  )
}