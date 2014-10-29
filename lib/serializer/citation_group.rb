module Serializer
  # Class to be used in (de)serializing Citation Groups.
  class CitationGroup < Serializer::Base 
    def self.to_json(o)
      { 'id'              => o.group_id,
        'word_position'   => o.word_position,
        'section'         => o.section,
        'context' => {
          'truncated_before' => o.truncated_before,
          'text_before'      => o.text_before,
          'citation'         => o.citation,
          'text_after'       => o.text_after,
          'truncated_after'  => o.truncated_after
        },
        'references'      => o.references.map(&:ref_id).presence
      }.compact
    end

    # Set the values in o according to the hash structure json
    def self.set_from_json(json, o)
      o.group_id = json['id']
      o.word_position = json['word_position']
      o.section = json['section']
      context = json['context']
      if context.present?
        o.truncated_before = context['truncated_before'] || false
        o.truncated_after = context['truncated_after'] || false
        o.citation = Serializer::Base.sanitize_html(context['citation'])
        o.text_before = Serializer::Base.sanitize_html(context['text_before'])
        o.text_after = Serializer::Base.sanitize_html(context['text_after'])
      end
      reference_ids = json['references']
      reference_ids && reference_ids.each do |ref_id|
        reference = o.citing_paper.reference_for_id(ref_id)
        raise "Reference #{ref_id.inspect} not found in citation group #{o.group_id.inspect}" unless reference
        o.references << reference
      end
    end
  end
end
