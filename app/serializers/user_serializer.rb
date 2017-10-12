class UserSerializer < ApplicationSerializer
  attributes :email

  has_many :accounts, each_serializer: AccountSerializer do
    object.accounts
  end

end
