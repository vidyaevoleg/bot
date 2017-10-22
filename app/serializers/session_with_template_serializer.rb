class SessionWithTemplateSerializer < SessionSerializer

  has_one :template, each_serializer: ::AccountTemplateSerializer do
    object.template
  end

end
