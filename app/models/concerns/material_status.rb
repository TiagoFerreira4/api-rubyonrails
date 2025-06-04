module MaterialStatus
  extend ActiveSupport::Concern

  VALID_STATUSES = %w[rascunho publicado arquivado].freeze

  included do
    validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  end

  def published?
    status == 'publicado'
  end

  def draft?
    status == 'rascunho'
  end

  def archived?
    status == 'arquivado'
  end
end