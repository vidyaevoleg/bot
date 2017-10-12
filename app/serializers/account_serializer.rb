class AccountSerializer < ApplicationSerializer
  attributes :secret, :key, :provider, :id

  has_one :template, serializer: AccountTemplateSerializer do
    object.template
  end

end
