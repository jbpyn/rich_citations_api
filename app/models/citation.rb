class Citation < ActiveRecord::Base

  # relationships
  belongs_to :cited_paper, class: Paper
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

  private

  def valid_uri
    parsed = URI.parse(uri)
    errors.add(:uri, 'must be a URI') if parsed.scheme.nil?
  rescue URI::InvalidURIError
    errors.add(:uri, 'must be a URI')
  end

end
