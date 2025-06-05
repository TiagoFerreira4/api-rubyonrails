# app/services/open_library_service.rb

require 'httparty'
require 'uri'

class OpenLibraryService
  BASE_URL = "https://openlibrary.org"

  def initialize(isbn)
    @isbn = isbn
  end

  #
  # Busca dados básicos do livro a partir do ISBN:
  #   - title
  #   - number_of_pages
  #   - authors (array de hashes contendo :name e :url)
  #
  def fetch_book_data
    url      = "#{BASE_URL}/api/books?bibkeys=ISBN:#{@isbn}&format=json&jscmd=data"
    response = HTTParty.get(url)
    data     = response.parsed_response["ISBN:#{@isbn}"]
    return nil unless data

    {
      title:           data["title"],
      number_of_pages: data["number_of_pages"],
      # Monta array de hashes: { name: "...", url: "https://openlibrary.org/authors/OLxxxA/..." }
      authors: data.fetch("authors", []).map do |a|
        {
          name: a["name"],
          url:  a["url"]
        }
      end
    }
  end

  #
  # Busca detalhes do autor (JSON) a partir da URL que veio no fetch_book_data.
  # Usa URI.escape para transformar caracteres Unicode em percent-encoding.
  #
  def fetch_author_details(author_url)
    # author_url virá como algo tipo:
    #   "https://openlibrary.org/authors/OL22242A/Фёдор_Михайлович_Достоевский"
    #
    # Transformamos em uma URL escapada e adicionamos “.json” no final:
    encoded = encode_url(author_url)
    json_url = "#{encoded}.json"

    response = HTTParty.get(json_url)
    data     = response.parsed_response
    return nil unless data.is_a?(Hash)

    {
      name:       data["name"],
      birth_date: data["birth_date"],
      death_date: data["death_date"]
    }
  end

  private

  # Garante que qualquer caractere fora do ASCII seja percent-encoded,
  # preservando barras ("/") e dois pontos (":") etc.
  def encode_url(url)
    # Exemplo:
    #   input:  "https://openlibrary.org/authors/OL22242A/Фёдор_Михайлович_Достоевский"
    #   output: "https://openlibrary.org/authors/OL22242A/%D0%A4%D1%91%D0%B4%D0%BE%D1%80_%D0%9C%D0%B8%D1%85%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2%D0%B8%D1%87_%D0%94%D0%BE%D1%81%D1%82%D0%BE%D0%B5%D0%B2%D1%81%D0%BA%D0%B8%D0%B9"
    #
    # URI.escape está obsoleto, então usamos URI::DEFAULT_PARSER to encode any non-ASCII chars:
    URI::DEFAULT_PARSER.escape(url)
  end
end
