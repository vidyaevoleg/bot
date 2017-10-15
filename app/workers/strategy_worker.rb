class StrategyWorker < ApplicationWorker

  def perform(account_id)
    account = ::Account.find(account_id)
    Strategy.new(account).call
  end

end
