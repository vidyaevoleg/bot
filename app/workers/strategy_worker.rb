class StrategyWorker < ApplicationWorker

  def perform(template_id)
    template = ::Account::Template.find(template_id)
    template.run_strategy
  end

end
