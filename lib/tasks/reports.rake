namespace :reports do
  task save: [:environment] do
    Account::Template.find_each do |t|
      Orders::SaveReportsWorker.perform_async(t.id)
    end
  end
end
