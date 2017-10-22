class StrategyWorker < ApplicationWorker

  def perform(template_id)
    template = ::Account::Template.find(template_id)
    Strategy.new(template).call
  end

end
