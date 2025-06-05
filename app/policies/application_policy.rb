class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true # Generally allow listing for authenticated users, can be overridden
  end

  def show?
    true # Generally allow showing for authenticated users, can be overridden
  end

  def create?
    user.present? # Only authenticated users can create by default
  end

  def new?
    create?
  end

  def update?
    user.present? && record.user == user # Default: only creator can update
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && record.user == user # Default: only creator can destroy
  end

  # Scope class for collection authorization (e.g., for index actions)
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve

      scope.all
    end
  end
end