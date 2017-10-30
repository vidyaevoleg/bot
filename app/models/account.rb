class Account < ActiveRecord::Base

  belongs_to :user
  enum provider: {bittrex: 0, poloniex: 1}
  has_many :templates, class_name: ::Account::Template, dependent: :destroy
  has_many :wallets, class_name: ::Account::Wallet, dependent: :destroy
  has_many :sessions, class_name: ::Account::Session, through: :templates
  has_many :orders, through: :templates

  validates :user, presence: true

  def create_default_template(options={})
    template = templates.create_default(options.merge(account: self))
  end

  def create_client
    provider_class.new(key: key, secret: secret)
  end

  def provider_class
    klass = provider.capitalize.constantize
    raise "NO PROVIDER class account #{id}" unless klass
    klass
  end

end
