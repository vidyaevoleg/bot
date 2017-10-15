module Orders
  class SaveOrderWorker < ::ApplicationWorker

    def perform(account_id, session_id, uuid, options={})
      account = ::Account.find(account_id)
      session = account.sessions.find(session_id)
      Orders::SaveOrder.run!(
        account: account,
        session: session,
        uuid: uuid,
        options: options.with_indifferent_access
      )
    end

  end
end
