module Accounts
  class SyncWalletsWorker < ::ApplicationWorker

    def perform(template_id)
      template = Account::Template.find(template_id)
      ::Accounts::SyncWallets.run!(template: template)
    end
  end
end
