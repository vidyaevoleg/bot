module Accounts
  class UpdateBlackListWorker < ::ApplicationWorker

    def perform(template_id, market_name)
      settings = Account::Template.find(template_id)
      new_black_list = settings.black_list
      new_black_list.delete(market_name)
      settings.update(black_list: new_black_list.uniq)
    end
  end
end
