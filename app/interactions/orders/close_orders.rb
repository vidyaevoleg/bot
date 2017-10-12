module Orders
  class CloseOrders < ::ApplicationInteraction
    object :account, class: ::Account

    def execute
      client = account.create_client
      opened_orders = client.orders.opened
      opened_ids = opened_orders.map(&:id)
      account.orders.pending.each do |order|
        if opened_ids.include?(order.uuid)
          remote_order = opened_orders.find {|o| o.id == order.uuid}
          remote_order.close!
          order.destroy!
        else
          if session
            Orders::SaveOrder.run(account: account, session: session, uuid: order.uuid)
            session.add_count(order.type)
          end
        end
      end
      if session
        session.update(status: 'completed')
      end
    end

    def session
      @_session ||= account.sessions.pending.last
    end
  end
end
