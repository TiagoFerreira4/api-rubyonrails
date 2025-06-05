module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers
      include Pundit::Authorization
      include ErrorHandler

      before_action :authenticate_user! # From Devise, ensures user is logged in via JWT

      private

      def current_user
        # Devise-JWT sets current_user if a valid token is present
        super
      end

      def render_json(data, status: :ok, blueprint: nil, view: :default, root: nil, **options) # Adicionado 'root'
        if blueprint && data
          # Se 'root' for fornecido, passe-o para o Blueprinter
          render_options = { view: view, **options }
          render_options[:root] = root if root
          render json: blueprint.render(data, **render_options), status: status
        elsif data # For simple messages or already formatted hashes
          render json: data, status: status
        else
          head status # For no content responses
        end
      end
    end
  end
end