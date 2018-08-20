module Orders
  class CreateWorker < ::ApplicationWorker
    sidekiq_options retry: false, backtrace: true

    def perform(template_id, session_id, params={}, options={})
      params = params.with_indifferent_access
      template = ::Account::Template.find(template_id)
      account = template.account
      client = account.create_client
      if Rails.env.development?
        begin
          client.markets.create!(params) do |created_order|
            uuid = created_order["uuid"]
            ::Orders::SaveOrderWorker.perform_async(template_id, session_id, uuid, options)
          end
        rescue RuntimeError => e
          puts e.message.red
        end
      else
        client.markets.create!(params) do |created_order|
          uuid = created_order["uuid"]
          ::Orders::SaveOrderWorker.perform_async(template_id, session_id, uuid, options)
        end
      end
    end

  end
end
