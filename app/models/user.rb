# app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Inclui a estratégia de revogação JTI para devise-jwt
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Configura os módulos do Devise.
  # :jwt_authenticatable e jwt_revocation_strategy são para devise-jwt.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Validações
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  # A validação de password_confirmation é feita automaticamente pelo Devise se password_confirmation estiver presente nos params

  # Associações
  has_many :materials, foreign_key: 'user_id', dependent: :destroy # Materiais criados por este usuário

  # O jti será adicionado por uma migração e é usado pelo Devise::JWT::RevocationStrategies::JTIMatcher
end