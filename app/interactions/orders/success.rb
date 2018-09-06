module Orders
  class Success < ApplicationInteraction

    object :order, class: Order

    def execute
      account = order.template.account
      client = account.create_client
      remote = client.remote_orders.find(order.uuid)
      order.update!(
        status: :completed,
        commission: remote.commission,
        profit: order.sell? ? profit : 0
      )
      self
    end

    private

    def profit
      sum = 0
      orders = Order.where(chain_id: order.chain_id)
      orders.each do |o|
        if o.sell?
          sum += (o.price * o.quantity - o.commission)
        elsif o.buy?
          sum -= (o.price * o.quantity + o.commission)
        end
      end
      sum
    end
  end
end
