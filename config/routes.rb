Rails.application.routes.draw do

  #@note simple versioning. Add something more robust later.

  concern :v0_routes  do
    scope module:'v0', controller:'api', constraints: { id:/[^\/]+/ }  do
      # Implement a standard rest API
      post '/papers', action:'create'
      get  '/papers', action:'show'
    end
  end

  namespace :v0 do
    concerns :v0_routes
  end

  # Default routes
  concerns :v0_routes

end
