class AccountTemplateBalanceSerializer < ApplicationSerializer
  attributes :currency, :available

  def available
    object.wallets.map {|w| w.available_currency}.inject(&:+).to_f.round(8)
  end

end
