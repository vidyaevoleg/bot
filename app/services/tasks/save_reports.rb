module Tasks
  class SaveReports

    def self.call
      Account::Template.find_each do |t|
        Orders::SaveReportsWorker.perform_async(t.id)
      end
    end

  end
end
