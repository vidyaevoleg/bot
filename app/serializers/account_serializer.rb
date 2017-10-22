class AccountSerializer < ApplicationSerializer
  attributes :secret, :key, :provider, :id

  has_many :templates, serializer: AccountTemplateSerializer do
    object.templates
  end

end
