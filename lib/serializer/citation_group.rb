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

module Serializer
  # Mixin to be used in (de)serializing Citation Groups.
  module CitationGroup
    def self.included base
      base.extend ClassMethods
    end

    def to_json(_opts = {})
      { 'id'              => self.group_id,
        'word_position'   => self.word_position,
        'section'         => self.section,
        'context' => {
          'truncated_before' => self.truncated_before,
          'text_before'      => self.text_before,
          'citation'         => self.citation,
          'text_after'       => self.text_after,
          'truncated_after'  => self.truncated_after
        },
        'references'      => self.references.map(&:ref_id).presence
      }.compact
    end

    # Set the values in o according to the hash structure json
    def set_from_json(json)
      self.group_id = json['id']
      self.word_position = json['word_position']
      self.section = json['section']
      context = json['context']
      if context.present?
        self.truncated_before = context['truncated_before'] || false
        self.truncated_after = context['truncated_after'] || false
        self.citation = Serializer::Helper.sanitize_html(context['citation'])
        self.text_before = Serializer::Helper.sanitize_html(context['text_before'])
        self.text_after = Serializer::Helper.sanitize_html(context['text_after'])
      end
      json['references'].each do |ref_id|
        reference = self.citing_paper.reference_for_id(ref_id)
        raise "Reference #{ref_id.inspect} not found in citation group #{self.group_id.inspect}" unless reference
        self.references << reference
      end
    end
  end
end
