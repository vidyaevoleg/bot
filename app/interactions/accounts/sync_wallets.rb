module Accounts
  class SyncWallets < ::ApplicationInteraction
    attr_reader :account

    object :template, class: ::Account::Template

    def execute
      @account = template.account
      client = account.create_client

      remote_wallets = client.wallets.all
      remote_wallets.each do |wallet|
        save_wallet(wallet)
      end
    end

    private

    def save_wallet(remote_wallet)
      wallet = account.wallets.find_by(currency: remote_wallet.currency)
      attrs = {
        currency: remote_wallet.currency,
        available: remote_wallet.available,
        available_btc: remote_wallet.available_btc
      }
      if wallet
        wallet.update!(attrs)
      else
        account.wallets.create(attrs)
      end
    end
  end
end
