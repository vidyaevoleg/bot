namespace :candles do
  task save: [:environment] do
    Account.pluck(:provider).uniq.each do |provider_num|
      provider_name = Account.providers.invert[provider_num]
      Candles::SaveProvider.new(provider_name).call
    end
  end
end
