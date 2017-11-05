class WalletSerializer < ApplicationSerializer
  attributes :currency, :available, :available_currency

  def available
    object.available.to_f.round(8)
  end

  def available_currency
    object.available_currency.to_f.round(8)
  end
end
