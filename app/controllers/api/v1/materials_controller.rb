# app/controllers/api/v1/materials_controller.rb

module Api
  module V1
    class MaterialsController < BaseController
      before_action :set_material, only: [:show, :update, :destroy]
      skip_before_action :authenticate_user!, only: [:show]

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
        # 1) Descobrir a classe (Book, Article ou Video)
        material_type_str = params.dig(:material, :type)&.camelize
        material_class    = material_type_str&.safe_constantize

        unless [::Book, ::Article, ::Video].include?(material_class)
          return render json: {
                           errors: [
                             "Tipo de material inválido. Use Book, Article ou Video."
                           ]
                         },
                         status: :unprocessable_entity
        end

        # 2) Converte ISBN vazio ("") em nil antes de qualquer outra coisa:
        if params[:material][:isbn].to_s.strip.blank?
          params[:material][:isbn] = nil
        else
          # remove espaços em branco extremidades
          params[:material][:isbn] = params[:material][:isbn].to_s.strip
        end

        # 3) Se for Book e houver ISBN, busque dados na Open Library
        if material_class == Book
          isbn_param = params.dig(:material, :isbn)&.to_s

          if isbn_param.present?
            ol_service = OpenLibraryService.new(isbn_param)
            book_data  = ol_service.fetch_book_data

            if book_data
              # 3.a) Preenche autor se veio do JSON e user não informou author_id
              if book_data[:authors].present? && params[:material][:author_id].blank?
                first_author = book_data[:authors].first
                author_name  = first_author[:name]
                author_url   = first_author[:url]

                # Busca detalhes do autor (incluindo birth_date),
                # agora com URL escapada internamente no serviço
                details   = ol_service.fetch_author_details(author_url)
                data_nasc = details && details[:birth_date]

                # Cria ou busca PersonAuthor, preenchendo date_of_birth se houver
                author = PersonAuthor.find_or_initialize_by(name: author_name)
                author.date_of_birth ||= data_nasc if data_nasc.present?

                # Salva sem validar (se faltar date_of_birth, ignoramos a falha de validação)
                author.save(validate: false) unless author.persisted?

                # Se criou ou achou, atribui o author_id
                params[:material][:author_id] = author.id if author.persisted?
              end

              # 3.b) Preenche título/páginas apenas se vierem em branco no form
              if params[:material][:title].blank? && book_data[:title].present?
                params[:material][:title] = book_data[:title]
              end

              if params[:material][:number_of_pages].blank? && book_data[:number_of_pages].present?
                params[:material][:number_of_pages] = book_data[:number_of_pages]
              end
            end
          end
        end

        # 4) Monta o objeto usando material_params_for (já incluindo author_id, se preenchido)
        @material      = material_class.new(material_params_for(material_class))
        @material.user = current_user

        authorize @material

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
        authorize @material
        material_class = @material.class

        # 1) Converte ISBN vazio ("") em nil:
        if params[:material][:isbn].to_s.strip.blank?
          params[:material][:isbn] = nil
        else
          params[:material][:isbn] = params[:material][:isbn].to_s.strip
        end

        # 2) Se for Book e houver ISBN, reaplica lógica de buscar dados
        if material_class == Book
          isbn_param = params.dig(:material, :isbn)&.to_s

          if isbn_param.present?
            ol_service = OpenLibraryService.new(isbn_param)
            book_data  = ol_service.fetch_book_data

            if book_data
              if book_data[:authors].present? && params[:material][:author_id].blank?
                first_author = book_data[:authors].first
                author_name  = first_author[:name]
                author_url   = first_author[:url]

                details   = ol_service.fetch_author_details(author_url)
                data_nasc = details && details[:birth_date]

                author = PersonAuthor.find_or_initialize_by(name: author_name)
                author.date_of_birth ||= data_nasc if data_nasc.present?
                author.save(validate: false) unless author.persisted?

                params[:material][:author_id] = author.id if author.persisted?
              end

              if params[:material][:title].blank? && book_data[:title].present?
                params[:material][:title] = book_data[:title]
              end

              if params[:material][:number_of_pages].blank? && book_data[:number_of_pages].present?
                params[:material][:number_of_pages] = book_data[:number_of_pages]
              end
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

      # Define quais campos são permitidos conforme o tipo de material
      def material_params_for(type_class)
        common_params  = [:title, :description, :status, :author_id, :type]
        book_params    = [:isbn, :number_of_pages]
        article_params = [:doi]
        video_params   = [:duration_minutes]

        permitted = common_params
        case type_class.to_s
        when "Book"
          permitted += book_params
        when "Article"
          permitted += article_params
        when "Video"
          permitted += video_params
        end

        params.require(:material).permit(*permitted)
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
