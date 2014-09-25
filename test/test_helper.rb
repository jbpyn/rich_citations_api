ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/test_unit'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Infer as many values as we can based on the index
  def new_reference(options={}, &block)
    save = options.delete(:save)

    if options[:cited_paper] && !options.has_key?(:uri) && options[:cited_paper].uri
      options[:uri] = options[:cited_paper].uri
    end

    if options[:number]
      options[:uri]    = "http://example.org/#{options[:number]}" unless options.has_key?(:uri)
      options[:ref_id] = "ref.#{options[:number]}"                unless options.has_key?(:ref_id)
    end

    if !options.has_key?(:cited_paper)
      uri = options[:uri]
      bib = options.delete(:bibliographic)
      options[:cited_paper] = Paper.new(uri:uri, bibliographic:bib)
    end

    result = Reference.new(options)

    if block_given?
      if block.arity==0
        result.instance_eval &block
      else
        yield self
      end
    end

    result.save! if save
    result
  end
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


end

class ActionController::TestResponse

  def json
    MultiJson.load(body)
  end

end
