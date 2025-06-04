# app/graphql/types/book_type.rb
module Types
  class BookType < Types::BaseObject
    implements MaterialInterface # Ensure this interface is defined

    # Own fields
    field :isbn, String, null: false
    field :number_of_pages, Integer, null: false
  end
end