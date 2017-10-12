module Accounts
  class UpdateTemplate < ::ApplicationInteraction
    object :account, class: Account
    integer :min_market_volume
    integer :min_sell_percent_diff
    integer :min_sell_percent_stop
    integer :min_buy_percent_diff
    integer :min_buy_sth_diff
    decimal :min_buy_price
    integer :interval

    def execute
      template = account.template || account.create_template
      template.update(inputs.except(:account))
    end

    def to_model
      account.reload
    end

  end
end
