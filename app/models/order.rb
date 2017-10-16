class Order < ActiveRecord::Base
  include SpreadsheetArchitect

  self.inheritance_column = nil
  belongs_to :account
  belongs_to :session, class_name: Account::Session
  enum status: {pending: 0, closed: 1, completed: 2}
  enum reason: {profit: 0, stop_loss: 1, buy_more: 2, future: 3, too_long: 4}

  def spreadsheet_columns
    [
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
      ['Yesterday price', yesterday_price]
    ]
  end

end
