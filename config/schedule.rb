output = "log/cron.log"

# every 1.day, :at => '0:00 am' do
#   runner "Tasks::SaveReports.call", output: output
# end

every 1.minute do
  rake "candles:save"
end


every 1.day do
  rake "log:clear"
end
