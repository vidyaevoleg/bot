module Orders
  class Create < ApplicationInteraction
    attr_reader :template, :remote, :order

    object :session, class: Account::Session
    string :reason
    hash :params, strip: false, default: {}

    def execute
      @template = session.template
      account = template.account
      client = account.create_client
      summary = client.summaries.all.find {|s| s.market == params[:sign] }
      client.markets.create!(params) do |created_order|
        uuid = created_order["uuid"]
        @remote = client.remote_orders.find(uuid)
        @order = template.orders.build(
          uuid: uuid,
          reason: reason,
          session: session,
          market: remote.market,
          quantity: remote.quantity,
          type: remote.type,
          commission: remote.commission,
          sell_count: summary.sell_count,
          buy_count: summary.buy_count,
          spread: summary.spread,
          yesterday_price: summary.yesterday_price,
          volume: summary.base_volume,
          chain_id: chain_id,
          price: params[:price]
        )
        order.save!
      end
    end

    def chain_id
      if reason.to_s == 'buy_more'
      elsif reason.to_s == 'buy'
        SecureRandom.hex(8)
      elsif remote.type == 'sell'
        order = Order.order(id: :desc).find_by(
          account_template_id: template.id,
          market: remote.market,
          reason: [:buy, :buy_more])
        order&.chain_id
      end
    end

  end
end
