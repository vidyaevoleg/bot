module Accounts
  class CheckAuth < ::ApplicationInteraction
    string :key
    string :secret
    string :provider

    def execute
      client = provider.capitalize.constantize.new(key: key, secret: secret)
      begin
        client.wallets.all
      rescue RuntimeError => e
        errors.add(:key, e.message)
      end
    end

  end
end
