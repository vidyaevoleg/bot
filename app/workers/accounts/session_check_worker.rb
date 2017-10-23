module Accounts
  class SessionCheckWorker < ::ApplicationWorker

    def perform(session_id)
      session = Account::Session.find(session_id)
      if session.orders.empty? && session.pending?
        session.template.run_strategy
      end
    end
  end
end
