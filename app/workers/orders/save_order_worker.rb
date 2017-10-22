module Orders
  class SaveOrderWorker < ::ApplicationWorker

    def perform(template_id, session_id, uuid, options={})
      template = ::Account::Template.find(template_id)
      session = template.sessions.find(session_id)
      Orders::SaveOrder.run!(
        template: template,
        session: session,
        uuid: uuid,
        options: options.with_indifferent_access
      )
    end

  end
end
