class Account::Report < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :template, class_name: ::Account::Template
  enum type: {daily: 0}
  serialize :payload, Hash
end
