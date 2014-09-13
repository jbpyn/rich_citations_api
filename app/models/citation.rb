class Citation < ActiveRecord::Base
  belongs_to :cited_paper, class: Paper
  belongs_to :citing_paper, class: Paper
  validates  :citing_paper, uniqueness: {scope: :cited_paper}

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

end
