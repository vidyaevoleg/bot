module Orders
  class Success < ApplicationInteraction

    object :order, class: Order

    def execute
      client = account.create_client
      remote = client.remote_orders.find(order.uuid)
      order.update!(
        status: :completed,
        commission: remote.commission
      )
      order.update!(profit: profit) if order.sell?
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
