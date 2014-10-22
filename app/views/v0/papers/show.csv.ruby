# -*- ruby-mode -*-
require 'csv'

def format_author(a)
  return nil if a.nil?
  return a['literal'] if a['literal'].present?
  "#{a['family']}, #{a['given']}"
end

return CSV.generate do |csv|
  csv << %w(citing_paper_uri
            citation_id
            reference_id
            reference_number
            original_reference
            citation_group_id
            cited_paper_uri
            cited_paper_uri_source
            word_position
            section
            type
            title
            journal
            author_count
            author1
            author2
            author3
            author4
            author5
            author_string)

  # @mentions will contain :count (the count of the mention of the
  # reference), :reference and :group
  @mentions.each do |mention|
    ref, group = mention[:reference], mention[:group]
    ref_id = ref.ref_id
    bibliographic = ref.bibliographic
    authors = bibliographic['author'] || []
    citation_id = "#{ref_id}_#{mention[:count]}"
    csv << [@paper.uri,
            citation_id,
            ref_id,
            ref.number,
            ref.original_citation,
            group.group_id,
            ref.uri,
            ref.uri_source,
            group.word_position,
            group.section,
            bibliographic['type'],
            bibliographic['title'],
            bibliographic['container-title'],
            authors.size,
            format_author(authors[0]),
            format_author(authors[1]),
            format_author(authors[2]),
            format_author(authors[3]),
            format_author(authors[4]),
            authors.map {|a| format_author(a) }.join('; ')]
  end
end
