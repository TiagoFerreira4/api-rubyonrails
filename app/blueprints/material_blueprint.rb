class MaterialBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :description, :status, :type, :created_at, :updated_at

  # Basic view for lists
  view :base do
    # fields already defined are included
  end

  # Extended view for single resource or when more detail needed
  view :extended do
    include_view :base
    association :author, blueprint: AuthorBlueprint do |material, _options|
        # This ensures the correct view (person/institution) is used for the author
        author = material.author
        if author.is_a?(PersonAuthor)
          AuthorBlueprint.render_as_hash(author, view: :person)
        elsif author.is_a?(InstitutionAuthor)
          AuthorBlueprint.render_as_hash(author, view: :institution)
        else
          AuthorBlueprint.render_as_hash(author) # Default view
        end
    end
    association :user, blueprint: UserBlueprint # Creator
  end

  # Default to extended for now
  # default_view :extended
end