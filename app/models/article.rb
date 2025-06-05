class Article < Material
  DOI_FORMAT = /\A10\.\d{4,9}\/[-._;()\/:A-Z0-9]+\z/i
  validates :doi, presence: true, uniqueness: true, format: { with: DOI_FORMAT, message: "must follow the standard DOI format (e.g., 10.1000/xyz123)" }
end