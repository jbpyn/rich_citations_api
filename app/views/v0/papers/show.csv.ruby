# -*- ruby-mode -*-
require 'csv'

def format_author(a)
  return nil if a.nil?
  return a['literal'] if a['literal'].present?
  "#{a['family']}, #{a['given']}"
end

return CSV.generate(force_quotes: true) do |csv|
  csv << %w(citing_paper_uri
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

  # @mentions will contain :count (the count of the mention of the
  # reference), :reference and :group
  @mentions.each do |mention|
    ref, group, paper = mention[:reference], mention[:group], mention[:paper]
    ref_id = ref.ref_id
    bibliographic = ref.bibliographic
    authors = bibliographic['author'] || []
    issn = bibliographic['ISSN']
    issn = issn.join(', ') if issn.is_a? Array
    mention_id = "#{ref_id}-#{mention[:count]}"
    csv << [paper.uri,
            mention_id,
            group.group_id,
            group.word_position,
            group.section,
            ref.number,
            ref_id,
            ref.citation_groups.size,
            ref.uri,
            ref.uri_source,
            bibliographic['type'],
            bibliographic['title'],
            bibliographic['container-title'],
            issn,
            authors.size,
            format_author(authors[0]),
            format_author(authors[1]),
            format_author(authors[2]),
            format_author(authors[3]),
            format_author(authors[4]),
            authors.map {|a| format_author(a) }.join('; '),
            ref.original_citation]
  end
end
