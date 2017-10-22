class SessionSerializer < ApplicationSerializer
  attributes :id, :buy_count, :sell_count, :status, :date, :created_at, :strategy

  has_one :template, each_serializer: ::AccountTemplateSerializer do
    object.template
  end

  has_many :orders, each_serializer: ::OrderSerializer do
    object.orders
  end

  def date
    object.created_at && object.created_at.strftime("%H:%M %d-%m-%Y")
  end

end
