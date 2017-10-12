class Account::Session < ActiveRecord::Base
  has_many :orders
  belongs_to :account
  enum status: {pending: 0, completed: 1}

  def add_count(type)
    if type == 'buy'
      update_column(:buy_count, buy_count + 1)
    elsif type == 'sell'
      update_column(:sell_count, sell_count + 1)
    end
  end
end
