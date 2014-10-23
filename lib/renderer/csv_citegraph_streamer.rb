require 'csv'
module Renderer
  class CsvCitegraphStreamer < ::Renderer::Base
    def initialize(io)
      @io = io
      @options = { force_quotes: true }
      headers = %w(citing_paper_uri
                   reference_uri)
      @io.write(CSV.generate_line(headers, @options))
    end

    # TODO - get mention count
    def write_line(citing_paper_uri, reference_uri)
      @io.write(CSV.generate_line([citing_paper_uri, reference_uri], @options))
    end

    def close
      @io.close
    end
  end
end
