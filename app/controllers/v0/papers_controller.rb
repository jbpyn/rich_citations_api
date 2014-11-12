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

module V0
  class PapersController < ::ApiController
    include ActionController::Live

    before_action :authentication_required!, except: [ :show ]
    before_action :paper_required, except: [:create]
    before_action :validate_schema, only: [:create]

    before_action only: [:show] do
      # citegraph is huge, require API key
      authentication_required! if
        request.format == Mime::CSV && request.params[:fields] == 'citegraph'
    end

    def create
      respond_to do |format|
        format.json do
          metadata = uploaded_metadata
          uri      = metadata['uri']

          render status: :forbidden,      text:'Paper already exists' and return if Paper.exists?(uri: uri)

          paper = Paper.new

          if paper.update_metadata( metadata, authenticated_user )
            response.location = papers_url(uri:paper)
            render text:'Document Created', status: :created
          else
            render_metadata_error(paper)
          end
        end
      end
    end

    def update
      respond_to do |format|
        format.json do
          render status: :error, text: nil and return if (@paper_q.size != 1)

          paper = @paper_q.first
          # Easiest to just delete the old references
          paper.references.destroy_all
          paper.citation_groups.destroy_all

          if paper.update_metadata(uploaded_metadata, authenticated_user)
            render status: :ok, text: nil
          else
            render_metadata_error(paper)
          end
        end
      end
    end

    def show
      head :ok and return if request.head?

      respond_to do |format|

        format.all do
          # pretty print if the client did not ask for JSON
          # specifically for better display in browser
          render text: MultiJson.dump(get_json, pretty: true), content_type: Mime::JSON
        end

        format.json do
          render text: MultiJson.dump(get_json, pretty: params[:pretty].present?), content_type: Mime::JSON
        end

        format.js do
          callback = params[:callback] || 'jsonpCallback'
          json     = MultiJson.dump(get_json)
          jsonp    = "#{callback}(#{json});"
          render text: jsonp
        end

        format.csv do
          headers['Content-Disposition'] = 'attachment; filename=rich_citations.csv'
          headers['Content-Type'] = Mime::CSV.to_s
          if params[:fields] == 'citegraph'
            streamer = Serializer::CsvStreamerRaw
                       .new(response.stream,
                            %w(citing_paper_uri
                               reference_uri
                               mention_count))
            begin
              q = Reference
                  .joins('INNER JOIN "papers" "cited_papers"  ON "cited_papers"."id"  = "references"."cited_paper_id"')
                  .joins('INNER JOIN "papers" "citing_papers" ON "citing_papers"."id" = "references"."citing_paper_id"')
                  .select('citing_papers.uri as citing', 'cited_papers.uri as cited', 'mention_count').reorder('')
              f = -> (d) { streamer.write_line_raw(d['citing'], d['cited'], d['mention_count']) }
              if (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL')
                # use postgres_cursor
                q.each_row(block_size: 10_000, &f)
              else
                q.each(&f)
              end
            ensure
              streamer.close
            end
          elsif fields[:paper] == [:uri]
            streamer = Serializer::CsvStreamerRaw.new(response.stream, %w(citing_paper_uri))
            begin
              @paper_q.find_each do |r|
                streamer.write_line_raw(r.uri)
              end
            ensure
              streamer.close
            end
          else
            streamer = Serializer::CsvStreamer.new(response.stream)
            begin
              @paper_q.load_all.find_each do |paper|
                paper.citation_groups.each do |group|
                  group.citation_group_references.each do |cgr|
                    # iterating over .references instead of
                    #   citation_group_references increases the
                    #   database hits
                    streamer.write_line(paper, group, cgr.reference)
                  end
                end
              end
            ensure
              streamer.close
            end
          end
        end
      end
    end

    private

    def fields
      if @fields.nil?
        @fields = { paper: nil, reference: nil }
        if params[:fields].is_a? String
          # only top level, papers fields
          @fields[:paper] = params[:fields].split(/,/).map(&:to_sym)
        elsif params[:fields].is_a? Hash
          params[:fields].each do |k, v|
            @fields[k.to_sym] = v.split(/,/).map(&:to_sym)
          end
        end
      end
      @fields
    end

    def get_json
      retval = @paper_q.map { |p| p.to_json(json_opts) }
      if plural_query
        retval
      else
        retval[0]
      end
    end

    def paper_required
      unless params[:uri].present? || params[:doi].present? || params[:random].present? || params[:all].present?
        render(status: :bad_request, text: 'neither uri nor doi provided') and return
      end

      if params[:all]
        @paper_q = if params[:nonciting].blank?
                     Paper.citing
                   else
                     Paper.all
                   end
      elsif params[:random]
        max = params[:random].to_i
        count = Rails.cache.fetch('paper_citing_count', :expires_in => 60.minutes) { Paper.citing.count }
        max = count if max > count
        @paper_q = Paper.citing.offset(rand(count - max + 1)).limit(max)
      else
        uri = params[:uri] || "http://dx.doi.org/#{URI.encode_www_form_component(params[:doi])}"
        @paper_q = Paper.where(uri: uri)
        render(status: :not_found, text: 'Not Found') and return unless @paper_q.size > 0
      end

      # improve selection if we only need the URI
      @paper_q = @paper_q.select('id', 'uri') if fields[:paper] == [:uri]
    end

    # return true if the user requested more than one paper
    def plural_query
      params[:all] || params[:random]
    end

    def uploaded_metadata
      @uploaded_metadata ||= MultiJson.load(request.body.read)
    end

    def validate_schema
      unless JSON::Validator.validate(Paper::JSON_SCHEMA, uploaded_metadata)
        msg = "JSON Validation errors:\n"
        JSON::Validator.fully_validate(Paper::JSON_SCHEMA, uploaded_metadata, errors_as_objects: true).each do |err|
          msg << "- #{err[:message]}\n"
        end
        render(status: :unprocessable_entity, text: msg)
      end
    end

    def json_opts
      if @json_opts.nil?
        @json_opts = { fields_paper: fields[:paper], fields_reference: fields[:reference] }
      end
      @json_opts
    end

    def render_metadata_error(paper)
      text = "Invalid Metadata:\n"
      ([paper] + paper.references + paper.citation_groups).each do |ref|
        unless ref.valid?
          ref.errors.messages.each do |k, v|
            next if (v == ['is invalid']) # useless message
            val = (ref.respond_to?(k) && ref.send(k)) || '(unknown)'
            text << "  #{k} #{v.join('; ')} #{val}\n"
          end
        end
      end
      render status: :unprocessable_entity, text: text
    end
  end
end
