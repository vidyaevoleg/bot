namespace :candles do
  task save: [:environment] do
    command = lambda {
      Account.pluck(:provider).uniq.each do |provider_num|
        provider_name = Account.providers.invert[provider_num]
        Candles::Save.new(provider_name).call
      end
    }
    command.call
    sleep 25
    command.call
  end
end
