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

    before_action :authentication_required!, :except => [ :show ]
    before_action :paper_required, except: [:create]
    before_action :validate_schema, only: [:create]
    before_action :clean_fields, :only => [:show]
    
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
            text = "Invalid Metadata:\n"
            ([paper] + paper.references + paper.citation_groups).each do |ref|
              unless ref.valid?
                ref.errors.messages.each do |k,v|
                  next if (v == ["is invalid"]) # useless
                  val = (ref.respond_to?(k) && ref.send(k)) || '(unknown)'
                  text << "  #{k} #{v.join('; ')} #{val}\n"
                end
              end
            end
            render text:text, status: :unprocessable_entity
          end
        end
      end
    end

    def show
      head :ok and return if request.head?
      include_cited = true # 'cited'.in?(includes)

      respond_to do |format|

        format.all do
          # pretty print if the client did not ask for JSON
          # specifically for better display in browser
          render text: MultiJson.dump(get_json(include_cited), pretty: true), content_type: Mime::JSON
        end

        format.json do
          render text: MultiJson.dump(get_json(include_cited), pretty: params[:pretty].present?), content_type: Mime::JSON
        end

        format.js do
          callback = params[:callback] || 'jsonpCallback'
          json     = MultiJson.dump(get_json(include_cited))
          jsonp    = "#{callback}(#{json});"
          render text: jsonp
        end

        format.csv do
          headers['Content-Disposition'] = 'attachment; filename=rich_citations.csv'
          headers['Content-Type'] = Mime::CSV.to_s
          if params[:fields] == 'citegraph'
            streamer = Serializer::CsvCitegraphStreamer.new(response.stream)
            begin
              q = Reference
                  .joins('LEFT OUTER JOIN "papers" "cited_papers"  ON "cited_papers"."id"  = "references"."cited_paper_id"')
                  .joins('LEFT OUTER JOIN "papers" "citing_papers" ON "citing_papers"."id" = "references"."citing_paper_id"')
                  .select('citing_papers.uri as citing', 'cited_papers.uri as cited', 'mention_count')
              f = -> (d) { streamer.write_line(d['citing'], d['cited'], d['mention_count']) }
              if (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL')
                # use postgres_cursor
                q.each_row(&f)
              else
                q.each(&f)
              end
            ensure
              streamer.close
            end
          else
            mention_counter = {}
            streamer = Serializer::CsvStreamer.new(response.stream)
            begin
              dump_paper = lambda do |paper|
                paper.citation_groups.each do |group|
                  group.citation_group_references.each do |cgr|
                    # iterating over .references instead of
                    #   citation_group_references increases the
                    #   database hits
                    ref = cgr.reference
                    mention_counter[ref.ref_id] ||= 0
                    streamer.write_line(paper, group, ref, mention_counter[ref.ref_id] += 1)
                  end
                end
              end
              if @paper_ids
                @paper_ids.each do |paper_id|
                  dump_paper.call(Paper.where(id: paper_id)
                          .includes(citation_groups:
                                      { citation_group_references:
                                          { reference: :cited_paper } }).first)
                end
              else
                dump_paper.call(@paper)
              end
            ensure
              streamer.close
            end
          end
        end
      end
    end

    private

    def clean_fields
      @fields = if params[:fields]
                  params[:fields].split(/,/).map(&:to_sym)
                else
                  nil
                end
    end

    def get_json(include_cited)
      if @paper_ids
        papers = Paper.where(id: @paper_ids).map do |paper|
          paper.to_json(include_cited: true, fields: @fields)
        end
        { 'papers' => papers }
      else
        @paper.to_json(include_cited: true, fields: @fields)
      end
    end
    
    def includes
      params[:include] ? params[:include].split(',') : []
    end

    def paper_required
      # very special
      return true if params[:format] == 'csv' && params[:fields] == 'citegraph'
      
      unless params[:uri].present? || params[:doi].present? || params[:random].present?
        render(status: :bad_request, text: 'neither uri nor doi provided') and return
      end
      uri = params[:uri] || "http://dx.doi.org/#{URI.encode_www_form_component(params[:doi])}"

      if params[:random]
        max = params[:random].to_i
        max = 100 if max > 100 && authenticated_user.blank?
        all_paper_ids = Rails.cache.fetch('top_paper_ids', expire: 1.hour) do
          Paper.where('references_count > 0').select('id').map(&:id)
        end
        @paper_ids = all_paper_ids.shuffle[0..(max - 1)]
      else
        @paper = Paper.find_by(uri: uri)
        render(status: :not_found, text: 'Not Found') and return unless @paper
      end
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

  end
end
