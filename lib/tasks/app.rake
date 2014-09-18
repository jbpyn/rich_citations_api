
namespace :app do

  namespace :user do

    desc 'Create a new user/api-key: app:user:create [name="name"] [email=email]'
    task :create => :environment do
      full_name = ENV['name']
      email     = ENV['email']
      user      = User.new(full_name:full_name, email:email)
      if user.save
         puts "Created user:"
         puts "   api-key: #{user.api_key}"
         puts "   name   : #{user.full_name || '[none]'}"
         puts "   e-mail : #{user.email     || '[none]'}"
      else
        fail "*** Failed to create user.\n  #{user.errors.full_messages}"
      end
    end

  end

end
