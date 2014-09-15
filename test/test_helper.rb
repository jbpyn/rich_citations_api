ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Infer as many values as we can based on the index
  def new_citation(options={}, &block)
    save = options.delete(:save)

    if options[:cited_paper] && !options.has_key?(:uri) && options[:cited_paper].uri
      options[:uri] = options[:cited_paper].uri
    end

    if options[:index]
      options[:uri] = "http://example.org/#{options[:index]}" unless options.has_key?(:uri)
      options[:ref] = "ref.#{options[:index]}"                unless options.has_key?(:ref)
    end

    if !options.has_key?(:cited_paper)
      uri = options[:uri]
      bib = options.delete(:bibliographic)
      options[:cited_paper] = Paper.new(uri:uri, bibliographic:bib)
    end

    result = Citation.new(options)

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

end

class ActionController::TestResponse

  def json
    MultiJson.load(body)
  end

end