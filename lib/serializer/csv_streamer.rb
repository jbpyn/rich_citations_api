require 'csv'

module Serializer
  class CsvStreamer
    def initialize(io)
      @io = io
      @options = { force_quotes: true }
      headers = %w(citing_paper_uri
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
                   reference_original_text)
      @io.write(CSV.generate_line(headers, @options))
    end

    def write_line(paper, group, ref, count)
      ref_id = ref.ref_id
      bibliographic = ref.bibliographic
      authors = bibliographic['author'] || []
      issn = bibliographic['ISSN']
      issn = issn.join(', ') if issn.is_a? Array
      mention_id = "#{ref_id}-#{count}"
      @io.write(CSV.generate_line([paper.uri,
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
                                   ref.original_citation], @options))
    end

    def close
      @io.close
    end
  end
end
