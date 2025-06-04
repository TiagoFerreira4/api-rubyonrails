require 'httparty'

class OpenLibraryService
  include HTTParty
  base_uri ENV['OPEN_LIBRARY_API_URL'] || 'https://openlibrary.org'

  def initialize(isbn)
    @isbn = isbn.to_s.strip
  end

  def fetch_book_data
    return nil unless @isbn.match?(/\A\d{13}\z/) # Validate ISBN format before calling

    options = {
      query: {
        bibkeys: "ISBN:#{@isbn}",
        format: "json",
        jscmd: "data"
      }
    }
    begin
      response = self.class.get("/api/books", options)
      if response.success? && response.parsed_response.present?
        data = response.parsed_response["ISBN:#{@isbn}"]
        return nil unless data # Book not found

        {
          title: data['title'],
          number_of_pages: data['number_of_pages'] || (data['pagination']&.match(/\d+/).to_s.to_i if data['pagination']),
          # authors: data['authors']&.map { |a| a['name'] }, # Example if you wanted author names
          # publish_date: data['publish_date']
        }.compact # Remove nil values
      else
        Rails.logger.error "OpenLibrary API Error for ISBN #{@isbn}: #{response.code} - #{response.message}"
        nil
      end
    rescue HTTParty::Error, SocketError => e # Handle network errors
      Rails.logger.error "OpenLibrary Service HTTParty/SocketError for ISBN #{@isbn}: #{e.message}"
      nil
    end
  end
end