class InstitutionAuthor < Author
  validates :name, length: { minimum: 3, maximum: 120 }
  validates :city, presence: true, length: { minimum: 2, maximum: 80 }
end