# app/graphql/types/author_type.rb
module Types
  class AuthorType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :type, String, null: false # PersonAuthor or InstitutionAuthor
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :materials, [Types::MaterialInterface], null: true # Changed to MaterialInterface

    # Conditional fields based on STI type
    field :date_of_birth, GraphQL::Types::ISO8601Date, null: true
    def date_of_birth
      object.is_a?(PersonAuthor) ? object.date_of_birth : nil
    end

    field :city, String, null: true
    def city
      object.is_a?(InstitutionAuthor) ? object.city : nil
    end
  end
end