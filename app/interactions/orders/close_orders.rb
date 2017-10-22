module Orders
  class CloseOrders < ::ApplicationInteraction
    object :template, class: ::Account::Template

    def execute
      client = account.create_client
      opened_orders = client.orders.opened
      opened_ids = opened_orders.map(&:id)
      template.orders.pending.each do |order|
        if opened_ids.include?(order.uuid)
          remote_order = opened_orders.find {|o| o.id == order.uuid}
          remote_order.close!
          order.destroy!
        else
          if session
            Orders::SaveOrder.run(template: template, session: session, uuid: order.uuid)
            session.add_count(order.type)
          else
            order.destroy
          end
        end
      end
      if session
        session.update(status: 'completed')
      end
    end

    private

    def account
      @_account ||= template.account
    end

    def session
      @_session ||= template.sessions.pending.last
    end
  end
end
