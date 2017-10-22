class Order < ActiveRecord::Base
  include SpreadsheetArchitect
  self.inheritance_column = nil
  belongs_to :template, class_name: Account::Template, foreign_key: :account_template_id
  belongs_to :session, class_name: Account::Session
  enum status: {pending: 0, closed: 1, completed: 2}
  enum reason: {profit: 0, stop_loss: 1, buy_more: 2, future: 3, too_long: 4, panic_sell: 5}
  serialize :template_data, Hash

  def spreadsheet_columns
    data = [
      ['Id', id],
      ['Opened date', created_at],
      ['Closed date', closed_at],
      ['Market', market ],
      ['Action', type],
      ['Quantity', quantity],
      ['Price', price],
      ['Commission', commission],
      ['Reason', reason],
      ['Market volume', volume],
      ['Spread', spread],
      ['BTC value', quantity.to_f * price.to_f],
      ['Sell count', sell_count ],
      ['Buy count', buy_count],
      ['Chain id', chain_id],
      ['Yesterday price', yesterday_price],
      ['interval', template_data[:interval]],
      ['min_market_volume', template_data[:min_market_volume]],
      ['min_sell_percent_diff', template_data[:min_sell_percent_diff]],
      ['min_market_volume', template_data[:min_market_volume]],
      ['min_sell_percent_diff', template_data[:min_sell_percent_diff]],
      ['min_sell_percent_stop', template_data[:min_sell_percent_stop]],
      ['min_buy_sth_diff', template_data[:min_buy_sth_diff]],
      ['min_buy_percent_diff', template_data[:min_buy_percent_diff]],
      ['min_buy_price', template_data[:min_buy_price]],
      ['white_list_coef', template_data[:white_list_coef]],
      ['currency', template.currency]
    ]

    data
  end

end
