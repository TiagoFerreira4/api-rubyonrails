class Author < ApplicationRecord
  has_many :materials, dependent: :restrict_with_error # Prevent author deletion if they have materials

  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: %w[PersonAuthor InstitutionAuthor] }


end