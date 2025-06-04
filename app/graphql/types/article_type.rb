# app/graphql/types/article_type.rb
module Types
  class ArticleType < Types::BaseObject
    implements MaterialInterface

    field :doi, String, null: false
  end
end