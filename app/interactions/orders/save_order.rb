module Orders
  class SaveOrder < ::ApplicationInteraction
    attr_reader :remote_order

    string :uuid
    object :account, class: Account
    object :session, class: Account::Session

    def execute
      client = account.create_client
      @remote_order = client.orders.find(uuid)

      local_order = account.orders.find_by(uuid: uuid)
      local_order = account.orders.build unless local_order

      local_order.assign_attributes(
        market: remote_order.market,
        quantity: remote_order.quantity,
        type: remote_order.type,
        price: remote_order.price,
        commission: remote_order.commission,
        status: status,
        uuid: uuid,
        session_id: session.id,
      )
      local_order.save!
    end

    private

    def status
      remote_order.closed.present? ? Order.statuses['completed'] : Order.statuses['pending']
    end

  end
end
