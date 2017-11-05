class AccountShowSerializer < AccountSerializer
  attributes :wallets

  def wallets
    object.templates.map do |template|
      AccountTemplateBalanceSerializer.new(template).as_json
    end
  end

end
