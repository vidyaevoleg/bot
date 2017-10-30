class Account::Wallet < ActiveRecord::Base
  belongs_to :account
end
