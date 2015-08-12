# Rails env
set :rails_env, :production

# Production server settings
role :app, '173.214.168.34'
role :web, '173.214.168.34'
role :db,  '173.214.168.34'

server '173.214.168.34', {
                           user: 'passenger',
                           roles: %{web app db},
                           ssh_options: {
                               keys: %w(C:/Users/Vincent/.ssh/ae_passenger_interserver),
                               forward_agent: false,
                               auth_methods: %w(publickey)
                           }
                       }
