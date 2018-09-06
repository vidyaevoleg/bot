module Orders
  class CloseOrders < ::ApplicationInteraction
    object :template, class: ::Account::Template

    def execute
      client = account.create_client
      opened_orders = client.remote_orders.opened
      opened_ids = opened_orders.map(&:id)
      template.orders.pending.each do |order|
        if opened_ids.include?(order.uuid)
          remote_order = opened_orders.find {|o| o.id == order.uuid}
          remote_order.close!
          order.destroy!
        else
          Success.run!(order: order)
        end
      end
      session.update(status: 'completed') if session
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
