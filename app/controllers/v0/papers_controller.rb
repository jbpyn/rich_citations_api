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
    before_action :authentication_required!, :except => [ :show ]
    before_action :paper_required, except: [:create]
    before_action :validate_schema, only: [:create]
    
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
      respond_to do |format|
        head :ok and return if request.head?
        include_cited = 'cited'.in?(includes)
        format.all do
          # pretty print if the client did not ask for JSON
          # specifically for better display in browser
          render json: MultiJson.dump(get_json(true), pretty: true), content_type: 'application/json'
        end
        format.json do
          render json: get_json(true)
        end
        format.csv do
          @mentions = []
          mention_counter = {}
          (@papers || [@paper]).each do |paper|
            paper.citation_groups.each do |group|
              group.references.each do |ref|
                mention_counter[ref.ref_id] ||= 0
                @mentions.push(paper: paper, count: mention_counter[ref.ref_id] += 1, group: group, reference: ref)
              end
            end
          end
          headers['Content-Disposition'] = "attachment; filename=rich_citations.csv"
          render content_type: 'text/csv'
        end
      end
    end

    private

    def get_json(include_cited)
      if @papers
        {'papers' => @papers.map {|paper| paper.metadata(include_cited)} }
      else
        @paper.metadata(include_cited)
      end
    end
    
    def includes
      params[:include] ? params[:include].split(',') : []
    end

    def paper_required
      unless params[:uri].present? || params[:doi].present? || params[:random].present?
        render(status: :bad_request, text: 'neither uri nor doi provided') and return
      end
      uri = params[:uri] || "http://dx.doi.org/#{URI.encode_www_form_component(params[:doi])}"
      if params[:random]
        max = params[:random].to_i
        max = 100 if (max > 100)
        @papers = Reference.all.group(:citing_paper_id).shuffle[0..max].map(&:citing_paper)
      else
        @paper = Paper.for_uri(uri)
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
