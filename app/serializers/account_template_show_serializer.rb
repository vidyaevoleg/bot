class AccountTemplateShowSerializer < AccountTemplateSerializer
  attributes :available, :provider

  has_many :reports, each_serializer: ReportSerializer do
    object.reports
  end

  has_many :wallets, each_serializer: WalletSerializer do
    object.wallets
  end

  def available
    object.wallets.pluck(:available_currency).inject(&:+).to_f.round(8)
  end

  def provider
    object.account.provider
  end

end
