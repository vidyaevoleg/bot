class Strategy::RankVolume < Strategy

  def get_summaries
    sums = client.summaries.all.find_all {|s| s.market.include?("#{currency}")}
    white_listed = sums.select {|s| settings.white_list.include?(s.market)}
    by_rank = sums.sort {|s| (s.spread * s.volume ) }
    (white_listed + by_rank).uniq
  end
end
