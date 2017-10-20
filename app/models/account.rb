class Account < ActiveRecord::Base
  include WorkersHelper

  belongs_to :user
  enum provider: {bittrex: 0}
  has_one :template, class_name: Account::Template
  has_many :orders
  has_many :sessions, class_name: Account::Session

  validates :user, presence: true

  def create_default_template
    template = Account::Template.create_default(account: self)
  end

  def create_client
    provider_class.new(key: key, secret: secret)
  end

  def provider_class
    klass = provider.capitalize.constantize
    raise "NO PROVIDER class account #{id}" unless klass
    klass
  end

  def coins_cache_key
    "#{provider}_coins"
  end
end
