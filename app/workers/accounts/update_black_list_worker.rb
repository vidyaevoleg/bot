module Accounts
  class UpdateBlackListWorker < ::ApplicationWorker

    def perform(account_id, market_name)
      account = Account.find(account_id)
      settings = account.template
      new_black_list = settings.black_list
      new_black_list.delete(market_name)
      settings.update(black_list: new_black_list)
    end
  end
end
