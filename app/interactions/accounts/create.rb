module Accounts
  class Create < ::ApplicationInteraction

    attr_reader :account

    object :user, class: User
    string :key
    string :secret
    string :provider

    def execute
      checking = compose(CheckAuth, key: key, secret: secret, provider: provider)
      if checking.valid?
        @account = user.accounts.create(key: key, secret: secret, provider: provider)
        template = account.create_default_template if account.valid?
      end
      self
    end

    def to_model
      account.reload
    end

  end
end
