module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization
      include ErrorHandler

      before_action :authenticate_user! # From Devise, ensures user is logged in via JWT

      private

      def current_user
        # Devise-JWT sets current_user if a valid token is present
        super
      end

      def render_json(data, status: :ok, blueprint: nil, view: :default, **options)
        if blueprint && data
          render json: blueprint.render(data, view: view, **options), status: status
        elsif data # For simple messages or already formatted hashes
          render json: data, status: status
        else
          head status # For no content responses
        end
      end
    end
  end
end