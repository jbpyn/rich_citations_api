module Serializer
  class Base
    def self.sanitize_html(html)
      html.present? ? Loofah.fragment(html).scrub!(Base::SANITIZER).scrub!(:strip).scrub!(:nofollow).to_s.presence : nil
    end

    SANITIZER = Rails::Html::PermitScrubber.new
    SANITIZER.tags = %w(a em i strong b u cite q mark abbr sub sup s wbr)
  end
end
