module Actions
  class Base

    attr_reader :summary, :template

    def initialize(summary, template, *args)
      @template = template
      @summary = summary
    end

    private

    def market_active?
      summary.base_volume.to_f > template.min_market_volume.to_f
    end

  end
end
