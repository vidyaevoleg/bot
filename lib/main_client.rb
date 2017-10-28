class MainClient
  HOST = 'https://bittrex.com/api/v1.1'

  attr_reader :key, :secret, :time, :cache

  def initialize(auth = {})
    @key    = auth[:key]
    @secret = auth[:secret]
    @time = Time.now.to_i
    @cache = {}
  end

  private

  def connection
    @connection ||= Faraday.new(:url => HOST) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end
