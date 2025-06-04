# app/controllers/api/v1/materials_controller.rb
module Api
  module V1
    class MaterialsController < BaseController
      before_action :set_material, only: [:show, :update, :destroy]
      skip_before_action :authenticate_user!, only: [:index, :show, :search] # Publicly viewable/searchable

      # GET /api/v1/materials
      # GET /api/v1/materials/search (could be same endpoint with query param)
      def index
        if params[:term].present?
          materials = Material.publicly_visible.search_by_term(params[:term])
                              .includes(:author, :user) # Eager load
                              .order(created_at: :desc)
                              .page(params[:page]).per(params[:per_page] || 10)
        else
          materials = Material.publicly_visible.includes(:author, :user) # Eager load
                              .order(created_at: :desc)
                              .page(params[:page]).per(params[:per_page] || 10)
        end
        render_json materials, blueprint: MaterialBlueprint, view: :extended, meta: pagination_dict(materials)
      end

      # GET /api/v1/materials/search (Alternative dedicated search endpoint)
      # def search
      #   term = params[:term]
      #   if term.blank?
      #     return render json: { error: "Search term is required" }, status: :bad_request
      #   end

      #   materials = Material.publicly_visible.search_by_term(term)
      #                         .includes(:author, :user)
      #                         .order(created_at: :desc)
      #                         .page(params[:page]).per(params[:per_page] || 10)
      #   render_json materials, blueprint: MaterialBlueprint, view: :extended, meta: pagination_dict(materials)
      # end


      # GET /api/v1/materials/:id
      def show
        authorize @material, :show? # Pundit check
        render_json @material, blueprint: material_blueprint_for(@material), view: :extended
      end

      # POST /api/v1/materials
      def create
        material_type_str = params.dig(:material, :type)&.camelize
        material_class = material_type_str&.safe_constantize

        unless [Book, Article, Video].include?(material_class)
          return render json: { errors: ["Invalid material type. Must be Book, Article, or Video."] }, status: :unprocessable_entity
        end

        @material = material_class.new(material_params_for(material_class))
        @material.user = current_user # Assign creator

        authorize @material # Pundit check for :create?

        if @material.save
          render_json @material, status: :created, blueprint: material_blueprint_for(@material), view: :extended
        else
          render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/materials/:id
      def update
        authorize @material # Pundit check for :update?

        material_class = @material.class # Book, Article, or Video
        if @material.update(material_params_for(material_class))
          render_json @material, blueprint: material_blueprint_for(@material), view: :extended
        else
          render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/materials/:id
      def destroy
        authorize @material # Pundit check for :destroy?
        @material.destroy
        head :no_content
      end

      private

      def set_material
        @material = Material.find(params[:id])
      end

      def material_params_for(type_class)
        common_params = [:title, :description, :status, :author_id, :type]
        book_params = [:isbn, :number_of_pages]
        article_params = [:doi]
        video_params = [:duration_minutes]

        allowed_params = common_params
        case type_class.to_s
        when "Book"
          allowed_params += book_params
        when "Article"
          allowed_params += article_params
        when "Video"
          allowed_params += video_params
        end
        params.require(:material).permit(*allowed_params)
      end

      def material_blueprint_for(material)
        case material
        when Book then BookBlueprint
        when Article then ArticleBlueprint
        when Video then VideoBlueprint
        else MaterialBlueprint # Fallback, though should ideally match
        end
      end

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end