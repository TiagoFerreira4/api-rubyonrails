class FrontendController < ApplicationController
  # Ensure ApplicationController inherits from ActionController::Base
  # and has access to helpers, sessions, etc.
  # This controller is for HTML views, not API.
  # It might need to handle authentication differently if session-based login is used for frontend.
  # For simplicity, this example assumes public viewing or minimal interaction.
  # If actions here require login, you might use standard Devise `before_action :authenticate_user!`

  layout 'application' # Assuming you have an application.html.erb

  def index
    # For simplicity, directly call the API using HTTParty or Faraday.
    # In a real app, you might have service objects or client-side JS making these calls.
    # This is a server-side rendering of API data.
    # Note: This is a simplified example. Error handling and complex API interactions
    # would require more robust code.

    # To make this work, your Rails app needs to be able to make HTTP requests to itself,
    # or you would need to call the service/model layer directly (better for server-side rendering).
    # For a truly "mini frontend consuming the API", it's usually client-side JS.
    # Given the constraints, let's try to call the model layer directly for "listing".

    @materials = Material.publicly_visible.includes(:author, :user)
                        .order(created_at: :desc)
                        .page(params[:page]).per(5) # Simple pagination for view
  end

  def new_material
    @material = Material.new # Generic, type will be set by form
    @authors = Author.order(:name).all
    # You might want to instantiate specific types like Book.new for the form
    # if your form is type-specific from the start.
    # For a generic form, you'd need to handle type selection.
  end

  # This is a very basic example and bypasses the actual API for creation.
  # A true "API consuming frontend" would use JavaScript to POST to the API endpoints.
  # This is more of a standard Rails form submission that mimics creating similar data.
  def create_material
    # This is a placeholder. A real frontend consuming the API would use JS to submit
    # to the API endpoints. This server-side action is not strictly "consuming the API".
    # For a true API consumption, you'd have a form that, upon submission, uses JavaScript
    # to make a POST request to /api/v1/materials.

    # For this "mini-frontend" using server-side ERB to simulate interaction:
    # This will NOT go through your API's authentication/authorization in the same way.
    # It assumes a logged-in user via standard Devise sessions if you have that for the frontend.
    # This part is tricky because the request is for a Rails app that *is* the API.

    # Let's assume for the spirit of "mini frontend", it means a simple way to *trigger* creation.
    # This is NOT a secure way if your main API relies on JWT.
    # This example needs `current_user` from Devise sessions.
    if current_user.nil? && Rails.env.development? # Allow anonymous creation in dev for demo
      flash[:alert] = "Warning: Creating material as anonymous (dev mode). For production, user must be logged in."
      # In a real scenario, you'd redirect to login or show an error.
      # Create a dummy user on the fly if none, ONLY for dev demo of this form.
      dev_user = User.first || User.create(email: "dev_frontend@example.com", password: "password", password_confirmation: "password")
      @user_for_material = dev_user
    elsif current_user.nil?
        flash[:error] = "You need to be logged in to create materials via this form."
        redirect_to new_user_session_path # Or your frontend login path
        return
    else
        @user_for_material = current_user
    end


    material_type_str = params.dig(:material, :type)&.camelize
    material_class = material_type_str&.safe_constantize

    unless [Book, Article, Video].include?(material_class)
      flash[:error] = "Invalid material type."
      @material = Material.new(material_params_from_frontend) # To repopulate form
      @authors = Author.order(:name).all
      render :new_material, status: :unprocessable_entity
      return
    end

    @material = material_class.new(material_params_from_frontend)
    @material.user = @user_for_material # Assign creator (logged-in user)

    if @material.save
      flash[:notice] = "#{material_class} was successfully created."
      redirect_to root_path
    else
      flash.now[:error] = "Error creating material: #{@material.errors.full_messages.join(', ')}"
      @authors = Author.order(:name).all
      render :new_material, status: :unprocessable_entity
    end
  end

  private

  def material_params_from_frontend

    params.require(:material).permit(
      :title, :description, :status, :author_id, :type,
      :isbn, :number_of_pages, # Book
      :doi,                   # Article
      :duration_minutes       # Video
    )
  end
end