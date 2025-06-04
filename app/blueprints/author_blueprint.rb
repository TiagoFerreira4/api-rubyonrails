class AuthorBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :type, :created_at, :updated_at

  view :person do
    fields :date_of_birth
  end

  view :institution do
    fields :city
  end

  # Default view can be simple name and type
  # Or a transformer can be used to dynamically include fields based on type.
  # For simplicity, define separate views or use associations for material details.

  # Example of dynamic fields (more complex, might need a transformer)
  # transformকেলেস Transformer do |author_object, options|
  #   if author_object.is_a?(PersonAuthor)
  #     [:date_of_birth]
  #   elsif author_object.is_a?(InstitutionAuthor)
  #     [:city]
  #   else
  #     []
  #   end
  # end
end