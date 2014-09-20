
namespace :app do

  namespace :user do

    desc 'Create a new user/api-key: app:user:create [name="name"] [email=email]'
    task :create => :environment do
      full_name = ENV['name']
      email     = ENV['email']
      user      = User.new(full_name:full_name, email:email)
      if user.save
         puts "Created user: #{user.display}"
         puts "     api-key: #{user.api_key}"
      else
        fail "*** Failed to create user.\n  #{user.errors.full_messages}"
      end
    end

  end

end
