module Api
  module V1
    class AuthorsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show] # Publicly viewable

      # GET /api/v1/authors
      def index
        authors = Author.order(name: :asc).page(params[:page]).per(params[:per_page] || 10)
        render_json authors, blueprint: AuthorBlueprint, meta: pagination_dict(authors)
      end

      # GET /api/v1/authors/:id
      def show
        author = Author.find(params[:id])
        render_json author, blueprint: AuthorBlueprint.with_view(author_view(author))
      end

      # POST /api/v1/authors
      def create
        # Determine type from params, default to PersonAuthor if not specified or invalid
        author_type = params.dig(:author, :type)&.safe_constantize
        author_type = PersonAuthor unless [PersonAuthor, InstitutionAuthor].include?(author_type)

        @author = author_type.new(author_params_for(author_type))

        if @author.save
          render_json @author, status: :created, blueprint: AuthorBlueprint.with_view(author_view(@author))
        else
          render json: { errors: @author.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/authors/:id
      def update
        @author = Author.find(params[:id])
        # For simplicity, we don't allow changing author type here.
        # If that's needed, it requires more complex logic.
        author_type_class = @author.class # PersonAuthor or InstitutionAuthor

        if @author.update(author_params_for(author_type_class))
          render_json @author, blueprint: AuthorBlueprint.with_view(author_view(@author))
        else
          render json: { errors: @author.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/authors/:id
      def destroy
        author = Author.find(params[:id])
        if author.destroy
          head :no_content
        else
          # This happens if restrict_with_error callback prevents deletion
          render json: { errors: author.errors.full_messages.presence || ["Cannot delete author with associated materials."] }, status: :unprocessable_entity
        end
      end

      private

      def author_params_for(type_class)
        common_params = [:name, :type]
        person_params = [:date_of_birth]
        institution_params = [:city]

        allowed_params = common_params
        if type_class == PersonAuthor
          allowed_params += person_params
        elsif type_class == InstitutionAuthor
          allowed_params += institution_params
        end
        params.require(:author).permit(*allowed_params)
      end

      def author_view(author)
        author.is_a?(PersonAuthor) ? :person : :institution
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