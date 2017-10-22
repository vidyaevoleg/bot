class MigrateOldOrdersData < ActiveRecord::Migration
  class Account < ActiveRecord::Base
    has_many :orders
    has_many :templates, class_name: ::Account::Template
    has_many :sessions, class_name: ::Account::Session
  end

  class Order < ActiveRecord::Base
    self.inheritance_column = nil
    belongs_to :account
  end

  class ::Account::Template < ActiveRecord::Base
    belongs_to :account
  end

  class ::Account::Session < ActiveRecord::Base
    belongs_to :account
  end

  def up
    Account.includes(:orders).find_each do |account|
      template = account.templates.first
      if template
        account.orders.update_all(account_template_id: template.id)
        account.sessions.update_all(account_template_id: template.id)
      end
    end
  end

  def down
  end
end
