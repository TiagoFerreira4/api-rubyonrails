class MaterialPolicy < ApplicationPolicy

  def show?

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

      if user.present?
        #
        scope.where(status: 'publicado').or(scope.where(user_id: user.id))
      else # Unauthenticated user
        scope.where(status: 'publicado')
      end

    end
  end
end