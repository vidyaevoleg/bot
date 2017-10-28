class Bittrex::Base < Bittrex
  def self.all
    if self != Bittrex::Base
      client.get(api_path).map{|data| new(data) }
    else
      []
    end
  end
end
