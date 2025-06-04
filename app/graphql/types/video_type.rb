# app/graphql/types/video_type.rb
module Types
  class VideoType < Types::BaseObject
    implements MaterialInterface

    field :duration_minutes, Integer, null: false
  end
end