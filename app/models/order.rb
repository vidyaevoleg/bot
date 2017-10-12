class Order < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :account
  belongs_to :session, class_name: Account::Session
  enum status: {pending: 0, closed: 1, completed: 2}
end
