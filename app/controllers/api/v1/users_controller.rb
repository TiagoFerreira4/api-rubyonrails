module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: [:create] # Allow unauthenticated user registration

      # POST /api/v1/signup
      def create
        user = User.new(user_params)
        if user.save


          render_json({ message: 'User created successfully. Please login.' }, status: :created, blueprint: UserBlueprint, data: user)
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end