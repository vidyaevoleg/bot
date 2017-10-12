class SessionSerializer < ApplicationSerializer
  attributes :id, :buy_count, :sell_count, :status, :date, :account_id, :created_at

  has_many :orders, each_serializer: ::OrderSerializer do
    object.orders
  end

  def date
    object.created_at.strftime("%H:%M %d-%m-%Y")
  end

end
