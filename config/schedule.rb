output = "log/cron.log"

# every 1.day, :at => '0:00 am' do
#   runner "Tasks::SaveReports.call", output: output
# end

every 30.seconds do
  runner "Candles::Save.call", output: output
end
