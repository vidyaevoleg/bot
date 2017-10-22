class Account < ActiveRecord::Base

  belongs_to :user
  enum provider: {bittrex: 0}
  has_many :templates, class_name: Account::Template, dependent: :destroy
  has_many :orders, through: :templates
  has_many :sessions, through: :templates, class_name: Account::Session

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
