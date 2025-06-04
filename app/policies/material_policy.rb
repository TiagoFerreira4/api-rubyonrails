class MaterialPolicy < ApplicationPolicy
  # Anyone can see a material if it's public (or any material if no specific public status)
  def show?
    # If a status like 'publicado' exists and implies public visibility:
    # record.publicly_visible? || (user.present? && record.user == user)
    # For this project, requirement is "Users can visualize materials publics de outros usuários."
    # And "Cada material só pode ser alterado ou removido pelo usuário que o cadastrou."
    # Assuming 'publicado' materials are for general viewing.
    record.status == 'publicado' || (user.present? && record.user == user)
  end

  def create?
    user.present? # Any authenticated user can create materials
  end

  def update?
    user.present? && record.user_id == user.id
  end

  def destroy?
    user.present? && record.user_id == user.id
  end

  # Scope for index actions, e.g., what materials a user can see in a list
  class Scope < Scope
    def resolve
      # Users can see all 'publicado' materials, plus their own drafts/archived items.
      # This logic might be better handled directly in the controller's query for simplicity,
      # but Pundit scopes are the "correct" place for collection-level authorization.
      if user.present? # Authenticated user
        # Return all public materials OR materials owned by the user.
        # This OR condition can be complex with pagination.
        # A simpler approach might be to filter in the controller based on params or always show public + own.
        scope.where(status: 'publicado').or(scope.where(user_id: user.id))
      else # Unauthenticated user
        scope.where(status: 'publicado')
      end
      # The MaterialsController already filters by .publicly_visible for index actions
      # when no specific user context is given for "all public materials".
      # Pundit scope can be used to further refine this if needed, e.g., for an admin backend.
      # For this API, the controller's filtering is primary for the public index.
      # If we had an admin dashboard for all materials, this scope would be different.
      # For now, let the controller's `Material.publicly_visible` be the main filter for public views.
      # If a user requests *their* materials, the controller should scope by `current_user.materials`.
      # This Pundit scope acts as a fallback or general rule.
    end
  end
end