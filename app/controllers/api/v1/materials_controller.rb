# app/controllers/api/v1/materials_controller.rb
module Api
  module V1
    class MaterialsController < BaseController
      before_action :set_material, only: [:show, :update, :destroy]
      # Removemos :search, pois não há action search definida aqui
      skip_before_action :authenticate_user!, only: [:index, :show]

      # GET /api/v1/materials
      def index
        if params[:term].present?
          # Busca por termo em título, descrição ou nome do autor, sem filtrar por status
          materials = ::Material
                        .joins(:author)
                        .where(
                          "materials.title ILIKE :t OR
                           materials.description ILIKE :t OR
                           authors.name ILIKE :t",
                          t: "%#{params[:term]}%"
                        )
                        .includes(:author, :user)
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(params[:per_page] || 10)
        else
          # Aqui não filtramos por nenhum status: TODOS os materiais entram
          materials = ::Material
                        .includes(:author, :user)
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(params[:per_page] || 10)
        end

        render_json materials,
                    blueprint: MaterialBlueprint,
                    view: :extended,
                    root: :materials,
                    meta: pagination_dict(materials)
      end

      # GET /api/v1/materials/:id
      def show
        authorize @material, :show?
        render_json @material,
                    blueprint: material_blueprint_for(@material),
                    view: :extended,
                    root: :material
      end

      # POST /api/v1/materials
      def create
        material_type_str = params.dig(:material, :type)&.camelize
        material_class    = material_type_str&.safe_constantize

        # Aqui garantimos que sejam as classes globais ::Book, ::Article e ::Video
        unless [::Book, ::Article, ::Video].include?(material_class)
          return render json: {
                           errors: [
                             "Invalid material type. Must be Book, Article, or Video."
                           ]
                         },
                         status: :unprocessable_entity
        end

        @material = material_class.new(material_params_for(material_class))
        @material.user = current_user

        authorize @material   # Pundit check para :create?

        if @material.save
          render_json @material,
                      status: :created,
                      blueprint: material_blueprint_for(@material),
                      view: :extended,
                      root: :material
        else
          render json: {
                   errors: @material.errors.full_messages
                 }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/materials/:id
      def update
        authorize @material  # Pundit check para :update?

        material_class = @material.class  # já será ::Book, ::Article ou ::Video
        if @material.update(material_params_for(material_class))
          render_json @material,
                      blueprint: material_blueprint_for(@material),
                      view: :extended,
                      root: :material
        else
          render json: {
                   errors: @material.errors.full_messages
                 }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/materials/:id
      def destroy
        authorize @material  # Pundit check para :destroy?
        @material.destroy
        head :no_content
      end

      private

      def set_material
        @material = ::Material.find(params[:id])
      end

      def material_params_for(type_class)
        common_params  = [:title, :description, :status, :author_id, :type]
        book_params    = [:isbn, :number_of_pages]
        article_params = [:doi]
        video_params   = [:duration_minutes]

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

      # Seleciona o Blueprint certo usando escopo global (::BookBlueprint etc.)
      def material_blueprint_for(material)
        case material
        when ::Book    then ::BookBlueprint
        when ::Article then ::ArticleBlueprint
        when ::Video   then ::VideoBlueprint
        else MaterialBlueprint   # fallback (não usado em geral)
        end
      end

      def pagination_dict(collection)
        {
          current_page: collection.current_page,
          next_page:    collection.next_page,
          prev_page:    collection.prev_page,
          total_pages:  collection.total_pages,
          total_count:  collection.total_count
        }
      end
    end
  end
end
