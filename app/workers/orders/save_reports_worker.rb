module Orders
  class SaveReportsWorker < ::ApplicationWorker

    def perform(template_id)
      template = Account::Template.find(template_id)
      ::Orders::SaveReports.run!(template: template)
    end

  end
end
