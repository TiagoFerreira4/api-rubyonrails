# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    # Devise JWT handles login via warden strategy and logout via revocation strategy
    # We define these routes in routes.rb and point them to devise_scope
    # This controller can be minimal or even absent if not adding custom behavior.
    # If you need custom responses, you might override Devise's SessionsController or JWT related controllers.

    # For the purpose of clarity, if you wanted a custom response on successful login:
    class SessionsController < Devise::SessionsController
      # respond_to :json # Handled by Devise JWT by default for configured paths

      # private
      # def respond_with(resource, _opts = {})
      #   render json: {
      #     status: { code: 200, message: 'Logged in successfully.' },
      #     data: UserBlueprint.render_as_hash(resource) # Assuming UserBlueprint exists
      #   }, status: :ok
      # end

      # def respond_to_on_destroy
      #   if current_user
      #     render json: {
      #       status: 200,
      #       message: "Logged out successfully"
      #     }, status: :ok
      #   else
      #     render json: {
      #       status: 401,
      #       message: "Couldn't find an active session."
      #     }, status: :unauthorized
      #   end
      # end
    end
  end
end