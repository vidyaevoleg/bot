
output = "#{Rails.root}/log/cron.log"

every 1.day, :at => '0:00 am' do
  runner "Tasks::SaveReports.call", output: output
end

every 5.minutes do
  runner "Candles::SaveCandles.call", output: output
end
