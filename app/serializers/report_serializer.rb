class ReportSerializer < ApplicationSerializer
  attributes :balance, :profit, :date, :strategy

  def balance
    object.balance.to_f.round(8)
  end

  def profit
    object.profit.to_f.round(8)
  end

  def date
    object.created_at.strftime("%d-%m-%Y")
  end
end
