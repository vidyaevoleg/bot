class User < ActiveRecord::Base
  devise :database_authenticatable, :validatable
  has_many :accounts
  has_many :templates, through: :accounts
end
