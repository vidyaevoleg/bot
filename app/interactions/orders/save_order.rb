require 'exchanges'

module Orders
  class SaveOrder < ::ApplicationInteraction
    attr_reader :remote_order, :local_order

    string :uuid
    object :template, class: Account::Template
    object :session, class: Account::Session
    hash :options, default: {} do
      integer :reason, default: nil
      decimal :spread, default: nil
      decimal :volume, default: nil
      decimal :yesterday_price, default: nil
      integer :sell_count, default: nil
      integer :buy_count, default: nil
    end

    def execute
      client = account.create_client
      @remote_order = client.remote_orders.find(uuid)
      @local_order = template.orders.find_by(uuid: uuid) || template.orders.build

      attrs = options.merge(
        market: remote_order.market,
        quantity: remote_order.quantity,
        type: remote_order.type,
        price: remote_order.price,
        commission: remote_order.commission,
        status: status,
        uuid: uuid,
        session_id: session.id,
        profit: profit,
        closed_at: remote_order.closed_at
      )
      attrs.merge!(chain_id: chain_id) unless completed?
      attrs.merge!(template_data: template.data) if completed?
      local_order.update_attributes(attrs)
    end

    private

    def profit
      if remote_order.type == 'sell' && remote_order.closed_at
        last_buy_order = Order.where(
          account_template_id: template.id,
          type: 'buy',
          market: remote_order.market
        ).last
        if last_buy_order && last_buy_order.price
          margin = (remote_order.price - last_buy_order.price) * remote_order.quantity
          margin - remote_order.commission.to_f.to_d - last_buy_order.commission.to_f.to_d
        end
      end
    end

    def completed?
      remote_order.completed?
    end

    def account
      @_account ||= template.account
    end

    def chain_id
      return unless options[:reason]
      reason = ::Order.reasons.invert[options[:reason]].to_sym
      if [:future].include?(reason)
        generate_chain_id
      elsif [:stop_loss, :too_long, :buy_more, :profit, :panic_sell].include?(reason)
        last_buy_order = template.orders.where(type: 'buy', market: remote_order.market).last
        last_buy_order.chain_id if last_buy_order
      end
    end

    def status
      completed? ? Order.statuses['completed'] : Order.statuses['pending']
    end

    def generate_chain_id
      Digest::MD5.hexdigest("#{Time.now.to_s}-#{remote_order.market}")
    end
  end
end
