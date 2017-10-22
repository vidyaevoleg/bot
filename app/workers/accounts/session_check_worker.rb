module Accounts
  class SessionCheckWorker < ::ApplicationWorker

    def perform(session_id)
      session = Account::Session.find(session_id)
      if session.orders.empty?
        Strategy.new(session.template).call
      end
    end
  end
end
