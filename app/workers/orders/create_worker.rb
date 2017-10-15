module Orders
  class CreateWorker < ::ApplicationWorker
    # sidekiq_options retry: false, backtrace: true

    def perform(account_id, session_id, params={}, options)
      params = params.with_indifferent_access
      account = ::Account.find(account_id)
      client = account.create_client
      if Rails.env.development?
        begin
          client.markets.create!(params) do |created_order|
            uuid = created_order["uuid"]
            ::Orders::SaveOrderWorker.perform_async(account_id, session_id, uuid, options)
          end
        rescue RuntimeError => e
          puts e.message.red
        end
      else
        client.markets.create!(params) do |created_order|
          uuid = created_order["uuid"]
          ::Orders::SaveOrderWorker.perform_async(account_id, session_id, uuid, options)
        end
      end
    end

  end
end
