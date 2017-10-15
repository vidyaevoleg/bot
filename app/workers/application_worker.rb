class ApplicationWorker
  include Sidekiq::Worker

  def self.perform_async(*args)
    if Rails.env.development?
      new.perform(*args)
    else
      super
    end
  end

end
