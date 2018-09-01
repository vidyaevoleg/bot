module Actions
  class Base

    attr_reader :summary, :template

    def initialize(summary, template, *args)
      @template = template
      @summary = summary
    end

    private



  end
end
