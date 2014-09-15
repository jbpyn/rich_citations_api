module V0
  class ApiController < ::ActionController::Base

    respond_to :json
    before_filter :paper_required, except: [:create]

    def create
      metadata = uploaded_metadata
      uri      = metadata['uri']

      render status: :forbidden,      text:'Paper already exists' and return if Paper.exists?(uri: uri)

      paper = Paper.new
      paper.assign_metadata(metadata)

      if paper.save
        render text:'Document Created', status: :created
      else
        render text:'Invalid Metadata', status: :unprocessable_entity
      end
    end

    def show
      include_citations = 'cited'.in?(includes)
      render  json: @paper.metadata(include_citations)
    end

    private

    def includes
      params[:include] ? params[:include].split(',') : []
    end

    def paper_required
      uri = URI.decode_www_form_component( params[:id] )
      @paper = Paper.for_uri(uri)
      render(status: :not_found, text: 'Not Found') unless @paper
      @paper
    end

    def uploaded_metadata
      request.request_parameters[:api]
    end

  end
end
