module Orders
  class SaveOrderWorker
    include Sidekiq::Worker

    def perform(account_id, session_id, uuid)
      account = ::Account.find(account_id)
      session = account.sessions.find(session_id)
      Orders::SaveOrder.run!(account: account, session: session, uuid: uuid)
    end

  end
end
