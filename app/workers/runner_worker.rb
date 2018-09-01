class RunnerWorker < ApplicationWorker

  def perform(template_id)
    template = ::Account::Template.find(template_id)
    template.run
  end

end
