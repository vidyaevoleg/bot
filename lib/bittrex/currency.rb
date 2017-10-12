class Bittrex::Currency < ::Bittrex::Base
  attr_reader :name, :abbreviation, :minimum_confirmation, :transaction_fee, :active, :raw

  alias_method :min_confirmation, :minimum_confirmation
  alias_method :fee, :transaction_fee

  def initialize(attrs = {})
    @name = attrs['CurrencyLong']
    @abbreviation = attrs['Currency']
    @transaction_fee = attrs['TxFee']
    @minimum_confirmation = attrs['MinConfirmation']
    @active = attrs['IsActive']
    @raw = attrs
  end

  def self.api_path
    'public/getcurrencies'
  end

end
