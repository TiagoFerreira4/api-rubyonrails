class Material < ApplicationRecord
  include MaterialStatus

  belongs_to :user # Creator
  belongs_to :author

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :user_id, presence: true
  validates :author_id, presence: true
  validates :type, presence: true, inclusion: { in: %w[Book Article Video] }

  scope :publicly_visible, -> { where(status: 'publicado') }

  # For search
  scope :search_by_term, lambda { |term|
    joins(:author)
      .where("materials.title ILIKE :term OR materials.description ILIKE :term OR authors.name ILIKE :term", term: "%#{term}%")
  }
end