require 'colorize'
# Sidekiq::Extensions.enable_delay!
class Strategy
  attr_reader :client,
    :account,
    :wallets,
    :summaries,
    :orders,
    :settings,
    :session

  STH = 0.00000001
  # CONFIG = {
  #   percent: 1, #yyyy # когда ask + STH больше последней цены покупки на этот процент
  #   min_volume: 20, #yn # минимальный объем рынка монеты в БТС необходимый для входа на покупку
  #   min_sth: 100, #yny # минималное кол-во STH в разнице (ask - STH) - (bid + STH) для покупки
  #   min_percent: 2, #yny # процент для этой разницы,
  #   min_price: 0.0006, # минимальная цена покупки в BTC,
  #   max_sell_percent: 7 # минимальный процент убытка перед продажей
  # }

  def initialize(account)
    @settings = account.template
    @account = account
    @client = account.create_client
    close_orders
    @summaries = client.summaries.btc.sort_by(&:spread).reverse
    @wallets = client.wallets.all
    @orders = client.orders.all
    keep_wallets
    @session = account.sessions.create(buy_count: 0, sell_count: 0, payload: "")
  end

  def call
    perform_next_run
    summaries.each do |summary|
      start(summary)
    end
  end

  def start(summary)
    wallet = summary.wallet
    if wallet && wallet.available > 0
      start_not_zero(summary, wallet)
    else
      start_zero(summary)
    end
  end

  def start_not_zero(summary, wallet)
    last_buy_order = orders.find do |order|
      order.market == wallet.sign && order.buy?
    end # нашли последний ордер с этим активом в истории

    if last_buy_order # если последний ордер то -
      if wallet.available_btc > 0.0005 # если бабок на кошельке больше чем столько то -
        last_price = last_buy_order.price # цена последнего ордера на покупку
        min_difference = 1.to_f + settings.min_sell_percent_diff.to_f / 100.to_f
        if ((summary.ask.to_d - STH.to_d) / last_price.to_d).to_f > min_difference # (ask + STH ) / last_price > на заданный процент
          volume = wallet.available
          rate = (summary.ask.to_d - STH.to_d).to_f
          new_order(summary, 'sell', volume, rate) # ордер на продажу
        else
          min_difference = 1.to_f + settings.min_sell_percent_stop.to_f / 100.to_f
          if last_buy_order.price > (min_difference.to_d * summary.ask.to_d).to_f # цена уменьшилась на этот процент
            volume = wallet.available
            rate = (summary.ask.to_d - STH.to_d).to_f
            new_order(summary, 'sell', volume, rate) #ордер на продажу
          end
        end
      end
    end
  end

  def start_zero(summary)
    if summary.base_volume > settings.min_market_volume.to_f
      min_percent = settings.min_buy_percent_diff.to_d / 100.to_d
      min_diff = settings.min_buy_sth_diff.to_f * STH.to_f

      condition1 = ((((summary.ask.to_d - STH.to_d) - (summary.bid.to_d + STH.to_d))) / (summary.bid.to_d + STH.to_d)).to_f > min_percent
      condition2 = ((summary.ask.to_d - STH.to_d) - (summary.bid.to_d + STH.to_d)).to_f > min_diff

      if condition1 && condition2
        rate = (summary.bid.to_d + STH.to_d).to_f
        volume = (settings.min_buy_price.to_d / rate.to_d).to_f
        if session.buy_count < max_buy_deals_count
          new_order(summary, 'buy', volume, rate)
        end
      end
    end
  end

  # def market_info(summary)
  #   wallet = summary.wallet
  #   puts "
  #     WALLET: #{summary.market}, #{wallet && wallet.available_btc} BTC, #{wallet && wallet.available} #{wallet && wallet.sign};
  #     MARKET: ask #{summary.ask}, bid #{summary.bid}
  #     ===========================================================
  #   ".yellow
  # end

  def full_balance
    btc_wallet.available
  end

  def btc_wallet
    @_btc_wallet = wallets.find {|w| w.currency == 'BTC'}
  end

  def max_buy_deals_count
    (full_balance.to_d / settings.min_buy_price.to_d).to_i
  end

  def new_order(summary, type, volume, price)
    sign = summary.market

    session.buy_count += 1 if type == 'buy'
    puts "#{type} ордер  #{sign} по цене #{price} объемом #{volume} #{Time.zone.now}".green

    ::Orders::CreateWorker.perform_async(account.id, session.id, {
      sign: sign,
      type: type,
      volume: volume,
      price: price
    })
  end

  private

  def keep_wallets
    summaries.each do |summary|
      wallet = wallets.find { |w| w.sign == summary.market }
      summary.wallet = wallet
    end
  end

  def perform_next_run
    StrategyWorker.perform_in(settings.interval.seconds, account.id)
  end

  def close_orders
    Orders::CloseOrders.run!(account: account)
  end
end
