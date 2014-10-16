# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


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

    desc 'Build API docs with pandoc'
    task :docbuild => :environment do
      md = File.join(Rails.root, 'docs', 'citation-api.md')
      html = File.join(Rails.root, 'app', 'views', 'doc', 'index.html')
      system("pandoc #{md} > #{html}")
    end
  end

end
