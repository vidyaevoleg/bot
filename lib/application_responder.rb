class ApplicationResponder < ActionController::Responder
  def api_behavior
    raise MissingRenderer.new(format) unless has_renderer?
    answer = resource.try(:to_model) || resource

    if get?
      display answer
    elsif post?
      display answer, :status => :created, :location => api_location
    else
      display answer
    end
  end
end
