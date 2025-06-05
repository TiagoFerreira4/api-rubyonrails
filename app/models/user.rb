# app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Inclui a estratégia de revogação JTI para devise-jwt
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Configura os módulos do Devise.

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Validações
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create


  # Associações
  has_many :materials, foreign_key: 'user_id', dependent: :destroy # Materiais criados por este usuário


end