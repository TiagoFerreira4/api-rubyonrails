# app/graphql/types/material_interface.rb
module Types
  module MaterialInterface
    include Types::BaseInterface
    # Common fields for all materials
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :status, String, null: false
    field :type, String, null: false # Book, Article, Video
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :author, Types::AuthorType, null: false
    # field :user, Types::UserType, null: false # Creator

    # Define how to resolve the concrete type
    definition_methods do
      def resolve_type(object, _context)
        case object
        when ::Book
          Types::BookType
        when ::Article
          Types::ArticleType
        when ::Video
          Types::VideoType
        else
          raise "Unknown Material type: #{object.class.name}"
        end
      end
    end
  end
end