class Account::Wallet < ActiveRecord::Base
  belongs_to :template, class_name: ::Account::Template, foreign_key: :account_template_id
end
