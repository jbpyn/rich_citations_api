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

require 'csv'

module Serializer
  class CsvStreamer < CsvStreamerRaw
    def initialize(io)
      @mention_counter = {}
      super(io,
            %w(citing_paper_uri
               mention_id
               citation_group_id
               citation_group_word_position
               citation_group_section
               reference_number
               reference_id
               reference_mention_count
               reference_uri
               reference_uri_source
               reference_type
               reference_title
               reference_journal
               reference_issn
               reference_author_count
               reference_author1
               reference_author2
               reference_author3
               reference_author4
               reference_author5
               reference_author_string
               reference_original_text))
    end

    def write_line(paper, group, ref)
      ref_id = ref.ref_id
      bibliographic = ref.bibliographic
      authors = bibliographic['author'] || []
      issn = bibliographic['ISSN']
      issn = issn.join(', ') if issn.is_a? Array
      @mention_counter[ref_id] ||= 0
      count = @mention_counter[ref.ref_id] += 1
      mention_id = "#{ref_id}-#{count}"
      write_line_raw(paper.uri,
                     mention_id,
                     group.group_id,
                     group.word_position,
                     group.section,
                     ref.number,
                     ref_id,
                     ref.mention_count,
                     ref.uri,
                     ref.uri_source,
                     bibliographic['type'],
                     bibliographic['title'],
                     bibliographic['container-title'],
                     issn,
                     authors.size,
                     Helper.format_author(authors[0]),
                     Helper.format_author(authors[1]),
                     Helper.format_author(authors[2]),
                     Helper.format_author(authors[3]),
                     Helper.format_author(authors[4]),
                     authors.map {|a| Helper.format_author(a) }.join('; '),
                     ref.original_citation)
    end
  end
end
