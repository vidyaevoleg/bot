module Stat
  class BasePresenter < ::ApplicationPresenter
    include SpreadsheetArchitect

    def self.to_csv(options={})
      instances = options[:instances].map {|order| new(order) }
      super(headers: false, instances: instances)
    end
  end
end
