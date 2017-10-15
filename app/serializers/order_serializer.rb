class OrderSerializer < ApplicationSerializer
  attributes :id, :market, :price, :quantity, :type, :commission, :reason
end
