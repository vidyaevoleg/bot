class Strategy::OnlySell < Strategy
  def call
    if summary.wallet
      Actions::Sell.new(summary, template, :stop_loss).call do |*args|
        yield(*args)
      end
    end
  end
end
