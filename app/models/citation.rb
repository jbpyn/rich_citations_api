class Citation < ActiveRecord::Base
  belongs_to :cited_paper, class: Paper
  belongs_to :citing_paper, class: Paper
  validates :citing_paper, uniqueness: {scope: :cited_paper}

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

end
