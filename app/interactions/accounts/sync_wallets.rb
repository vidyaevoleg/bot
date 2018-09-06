module Accounts
  class SyncWallets < ::ApplicationInteraction
    attr_reader :account, :saved_ids

    object :template, class: ::Account::Template

    def execute
      @account = template.account
      @saved_ids = []
      client = account.create_client
      remote_wallets = client.wallets.all.find_all {|w| w.balance > 0}
      remote_wallets.each do |wallet|
        save_wallet(wallet)
      end
      template.wallets.where.not(id: saved_ids).destroy_all
    end

    private

    def save_wallet(remote_wallet)
      wallet = template.wallets.find_by(currency: remote_wallet.currency)
      attrs = {
        currency: remote_wallet.currency,
        available: remote_wallet.balance,
        available_currency: remote_wallet.available_currency(template.currency)
      }
      if wallet
        wallet.update!(attrs)
      else
        wallet = template.wallets.create!(attrs)
      end
      saved_ids << wallet.id
    end
  end
end
