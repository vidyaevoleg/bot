class Runner
  class InfucientFoundsError < StandardError ; end

  attr_reader :client,
    :account,
    :template,
    :wallets,
    :summaries,
    :orders,
    :session,
    :currency

  attr_accessor :used_balance


  def initialize(template)
    @template = template
    @account = template.account
    return if other_templates_running?
    @currency = template.currency
    @client = account.create_client
    @summaries = get_summaries
    @wallets = client.wallets.all
    @session = template.sessions.create(buy_count: 0, sell_count: 0, payload: "", strategy: template.strategy)
    @used_balance = 0.0
  end

  def call
    template.clear_workers
    close_orders
    save_coins
    keep_wallets
    perform_next_run
    summaries.each do |summary|
      next unless need_call?(summary)
      available_balance = full_balance - used_balance
      begin
        strategy_class = Strategy.const_get(template.strategy.capitalize)
        strategy_class.new(summary, template, available_balance).call do |*args|
          new_order(*args)
        end
      rescue InfucientFoundsError => e
        puts e
      end
    end
    perform_check
    save_last_call
  end

  private

  def need_call?(summary)
    !our_currencies.include?(summary.market)
  end

  def full_balance
    currency_wallet.available
  end

  def currency_wallet
    @_currency_wallet ||= wallets.find {|w| w.currency == currency}
  end

  def max_buy_deals_count
    (full_balance.to_d / template.min_buy_price.to_d).to_i
  end

  def other_templates_running?
    account.templates.where.not(id: template.id).map(&:off?).include?(false)
  end

  def new_order(summary, type, price, volume, reason = nil)
    sign = summary.market
    @used_balance = (used_balance.to_f + price * volume) if type == 'buy'
    puts "#{type} ордер  #{sign} по цене #{price} объемом #{volume} #{Time.zone.now} reason #{reason}".green
    puts "USED BALANCE #{used_balance}".green
    ::Orders::CreateWorker.perform_async(session.id, reason, {
      sign: sign,
      type: type,
      volume: volume,
      price: price,
    })
  end

  def save_coins
    Rails.cache.write(template.coins_cache_key, summaries.map(&:market))
  end

  def get_summaries
    sums = client.summaries.all.find_all {|s| s.market.include?("#{currency}") && !s.market.include?("USD") }
    sums.sort_by(&:base_volume).reverse
  end

  def keep_wallets
    summaries.each do |summary|
      wallet = wallets.find { |w| w.sign(template.currency) == summary.market }
      summary.define_singleton_method :wallet, -> { wallet }
    end
    Accounts::SyncWalletsWorker.perform_async(template.id)
  end

  def our_currencies
    return @_our_currencies if @_our_currencies
    words = account.templates.map {|t| "#{t.currency}"}
    @_our_currencies = []
    words.each do |word1|
      words.reverse.each do |word2|
        @_our_currencies << "#{word1}-#{word2}"
        @_our_currencies << "#{word2}-#{word1}"
        @_our_currencies << "#{word2}_#{word1}"
        @_our_currencies << "#{word1}_#{word2}"
      end
    end
    @_our_currencies.uniq
  end

  def save_last_call
    template.update!(last_time: Time.zone.now)
  end

  def perform_next_run
    RunnerWorker.perform_in(template.interval.seconds, template.id)
  end

  def perform_check
    Accounts::SessionCheckWorker.perform_in(30.seconds, session.id)
  end

  def close_orders
    Orders::CloseOrders.run!(template: template)
  end
end
