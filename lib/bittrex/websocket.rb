class Bittrex::Websocket

  WSS_HOST = 'wss://beta.bittrex.com/signalr'.freeze
  SIGNALR_URL = 'https://socket.bittrex.com/signalr/negotiate'.freeze
  RECONNECT_INTERVAL = 1.freeze

  attr_reader :key, :secret, :frames, :ws_token, :logger

  def initialize()
    @logger             = Rails.logger
    @frames             = []
  end


  def call
    ws_client = Faye::WebSocket::Client.new("#{WSS_HOST}")
    EM.run do
      ws_client.on(:open) do |event|
        byebug
        ws_client.send('SubscribeToExchangeDeltas', 'BTC-ETH')
      end

      ws_client.on(:message) do |event|
        byebug
        on_message(event)
      end
      byebug
      ws_client.on(:close) do |event|
        on_close(event)
        EM.add_timer(RECONNECT_INTERVAL) do
          to_log_error "DISCONNECTED!!! #{event.code}, #{event.reason}"\
                       '... try reconnect.'
          call
        end
      end
    end
  end

  private

  def on_open(_event)
    to_log('Connection opened successfully')

    # @ws_client.send({
    #   'H' => 'corehub', 'M' => 'SubscribeToExchangeDeltas'
    # })
  end

  def on_message(event)
    byebug
    data = JSON.parse(event.data)
    return nil if data == {}
    frame = Frame.new(data)
    @frames << frame
    to_log("WebSocket frame: #{event.data.to_s[0...300]}")
  end

  def on_close(event)
    to_log("Connection closed!!! #{event.code}, #{event.reason}")
  end

  def to_log(text)
    logger.info(text)
  end

  def to_log_error(text)
    logger.error(text)
  end
end
