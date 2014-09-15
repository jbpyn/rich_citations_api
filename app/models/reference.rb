class Reference < ActiveRecord::Base

  # relationships
  belongs_to :cited_paper,  class: Paper, validate:true, autosave:true
  belongs_to :citing_paper, class: Paper

  # validations
  validates  :citing_paper, presence:true
  validates  :cited_paper,                 uniqueness: {scope: :citing_paper}
  validates  :index,        presence:true, uniqueness: {scope: :citing_paper}
  validates  :uri,          presence:true, uniqueness: {scope: :citing_paper}
  validates  :ref,          presence:true, uniqueness: {scope: :citing_paper}
  validate   :valid_uri

  def text
    raw = read_attribute('text')
    @text ||= raw && MultiJson.load(raw)
  end

  def text= value
    @text = nil
    write_attribute('text', value && MultiJson.dump(value) )
  end

  def reload
    super
    @text = nil
  end

  def metadata(include_cited_paper=false)
    result = (text || {}).merge( 'index' => index,
                                 'uri'   => uri,
                                 'ref'   => ref         )

    if include_cited_paper && cited_paper
      result['bibliographic'] = cited_paper.bibliographic
    end

    result
  end
  alias :to_json metadata

  #@todo: This method needs to make sure that it doesn't leave orphan
  #       Cited records when they are automatically generated (Have a random_citation_uri)
  def assign_metadata(ref, metadata)
    metadata = metadata.dup
    uri      = metadata.delete('uri') || random_citation_uri

    if ref != metadata.delete('ref')
      raise "rexternal ref does not match fragment ref for #{ref}" #@todo
    end

    bibliographic = metadata.delete('bibliographic')
    cited_paper   = Paper.for_uri(uri)

    unless cited_paper || bibliographic
      raise "Cannot assign metadata unless the paper exists or bibliographic metadata is provided for #{ref}" #@todo
    end

    if bibliographic
      if cited_paper
        cited_paper.bibliographic = bibliographic
      else
        cited_paper = Paper.new(uri:uri, bibliographic:bibliographic)
      end
    end

    self.uri         = uri
    self.ref         = ref
    self.index       = metadata.delete('index')
    self.text        = metadata
    self.cited_paper = cited_paper
  end

  def is_random_uri?
    /^cited:/ === uri
  end

  private

  def random_citation_uri
    "cited:#{SecureRandom.uuid}"
  end

  def valid_uri
    parsed = URI.parse(uri)
    errors.add(:uri, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    errors.add(:uri, 'must be a URI')
  end

end
