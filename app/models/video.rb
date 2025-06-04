class Video < Material
  validates :duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
end