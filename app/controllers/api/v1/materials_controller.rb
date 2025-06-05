# app/controllers/api/v1/materials_controller.rb
module Api
  module V1
    class MaterialsController < BaseController
      before_action :set_material, only: [:show, :update, :destroy]
      skip_before_action :authenticate_user!, only: [:show]
      # OBS: Removemos :index da lista de skip, porque agora queremos exigir login para ver a lista

      # GET /api/v1/materials
      def index
        if params[:term].present?
          materials = current_user.materials
                                  .joins(:author)
                                  .where(
                                    "materials.title ILIKE :t OR
                                     authors.name ILIKE :t",
                                    t: "%#{params[:term]}%"
                                  )
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(params[:per_page] || 10)
        else
          materials = current_user.materials
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(params[:per_page] || 10)
        end

        render_json(
          materials,
          blueprint: MaterialBlueprint,
          view: :extended,
          root: :materials,
          meta:    pagination_dict(materials)
        )
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
        # 1) Descobrir qual classe (Book, Article ou Video)
        material_type_str = params.dig(:material, :type)&.camelize
        material_class    = material_type_str&.safe_constantize

        unless [::Book, ::Article, ::Video].include?(material_class)
          return render json: {
                           errors: [
                             "Invalid material type. Must be Book, Article, or Video."
                           ]
                         },
                         status: :unprocessable_entity
        end

        # 2) SE for livro (Book) e veio ISBN, tente buscar título e páginas na Open Library
        if material_class == Book
          isbn_param = params.dig(:material, :isbn).to_s.strip

          if isbn_param.present? &&
             (params[:material][:title].blank? || params[:material][:number_of_pages].blank?)
            ol_service = OpenLibraryService.new(isbn_param)
            ol_data    = ol_service.fetch_book_data

            if ol_data
              # Só sobrescreve se title/páginas estiverem em branco
              params[:material][:title]           = ol_data[:title]           if params[:material][:title].blank?
              params[:material][:number_of_pages] = ol_data[:number_of_pages] if params[:material][:number_of_pages].blank?
            end
          end
        end

        # 3) Com o params já modificado (se foi Book), chame material_params_for
        @material = material_class.new(material_params_for(material_class))
        @material.user = current_user

        authorize @material   # Pundit: verifica se current_user pode criar

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
        authorize @material  # Só permite se for dono (ou outra regra no Pundit)

        material_class = @material.class

        # Se for Book e usuário quiser alterar ISBN, podemos repetir a mesma lógica de busca de dados...
        if material_class == Book
          isbn_param = params.dig(:material, :isbn).to_s.strip

          if isbn_param.present? &&
             (params[:material][:title].blank? || params[:material][:number_of_pages].blank?)
            ol_service = OpenLibraryService.new(isbn_param)
            ol_data    = ol_service.fetch_book_data

            if ol_data
              params[:material][:title]           = ol_data[:title]           if params[:material][:title].blank?
              params[:material][:number_of_pages] = ol_data[:number_of_pages] if params[:material][:number_of_pages].blank?
            end
          end
        end

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
        authorize @material
        @material.destroy
        head :no_content
      end

      private

      def set_material
        @material = Material.find(params[:id])
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

      def material_blueprint_for(material)
        case material
        when ::Book    then ::BookBlueprint
        when ::Article then ::ArticleBlueprint
        when ::Video   then ::VideoBlueprint
        else MaterialBlueprint
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
