module Orders
  class SaveOrderWorker < ::ApplicationWorker

    def perform(account_id, session_id, uuid, options={})
      account = ::Account.find(account_id)
      session = account.sessions.find(session_id)
      Orders::SaveOrder.run!(
        account: account,
        session: session,
        uuid: uuid,
        reason: options.with_indifferent_access[:reason]
      )
    end

  end
end
