module WorkersHelper

  def clear_workers
    clear_queues
    clear_shedule_sets
  end

  def clear_queues
    queue =  Sidekiq::Queue.new
    queues = queue.select {|k| k.klass == 'Orders::CreateWorker' && k.args[0] == id}
    queues.each(&:delete)
  end

  def clear_shedule_sets
    set =  Sidekiq::ScheduledSet.new
    sets = set.select {|k| k.klass == 'RunnerWorker' && k.args[0] == id}
    sets.each(&:delete)
  end

end
