module Orders
  class CreateWorker < ::ApplicationWorker
    sidekiq_options retry: false, backtrace: true

    def perform(session_id, reason, params={})
      params = params.with_indifferent_access
      session = Account::Session.find(session_id)
      Orders::Create.run!(session: session, reason: reason.to_s, params: params)
    end

  end
end
