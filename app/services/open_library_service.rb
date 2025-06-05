# app/services/open_library_service.rb

require 'httparty'

class OpenLibraryService
  include HTTParty
  base_uri ENV['OPEN_LIBRARY_API_URL'] || 'https://openlibrary.org'

  def initialize(isbn)
    # Remove espaços, hífens e quaisquer caracteres não numéricos ou 'X'
    # Exemplo: "978-0140328721" → "9780140328721"
    @isbn = isbn.to_s.gsub(/[^0-9Xx]/, '')
  end

  def fetch_book_data
    # Aceita ISBN-10 (10 dígitos, último dígito pode ser 'X' maiúsculo ou minúsculo)
    # ou ISBN-13 (13 dígitos numéricos)
    return nil unless @isbn.match?(/\A(\d{10}|\d{13})\z/)

    options = {
      query: {
        bibkeys: "ISBN:#{@isbn}",
        format:  'json',
        jscmd:   'data'
      }
    }

    response = self.class.get('/api/books', options)
    return nil unless response.success?

    raw = response.parsed_response["ISBN:#{@isbn}"]
    return nil unless raw

    {
      title:           raw['title'],
      number_of_pages: extract_page_count(raw),
      authors:         extract_authors(raw),
      publish_date:    raw['publish_date']
    }.compact
  rescue HTTParty::Error, SocketError => e
    Rails.logger.error "OpenLibraryService error fetching ISBN #{@isbn}: #{e.message}"
    nil
  end

  private

  def extract_page_count(raw_data)
    # Tenta usar o campo 'number_of_pages'; se não existir, tenta extrair de 'pagination'
    if raw_data['number_of_pages'].present?
      raw_data['number_of_pages'].to_i
    elsif raw_data['pagination'].present?
      match = raw_data['pagination'].match(/(\d+)\s*páginas/i)
      match ||= raw_data['pagination'].match(/(\d+)/)
      match ? match[1].to_i : nil
    else
      nil
    end
  end

  def extract_authors(raw_data)
    return nil unless raw_data['authors'].is_a?(Array)
    raw_data['authors'].map { |a| a['name'] }
  end
end
