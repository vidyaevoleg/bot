module Actions
  class Base

    attr_reader :summary, :template, :reason

    def initialize(summary, template, reason = nil, *args)
      @template = template
      @summary = summary
      @reason = reason
    end

  end
end
