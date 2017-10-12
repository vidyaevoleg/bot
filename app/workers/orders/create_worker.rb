module Orders
  class CreateWorker
    include Sidekiq::Worker

    def perform(account_id, session_id, params={})
      account = ::Account.find(account_id)
      client = account.create_client
      client.markets.create!(params) do |created_order|
        uuid = created_order["uuid"]
        ::Orders::SaveOrderWorker.perform_async(account_id, session_id, uuid)
      end
    end

  end
end
