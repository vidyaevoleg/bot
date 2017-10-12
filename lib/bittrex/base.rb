class Bittrex::Base

  def self.all
    if self != Bittrex::Base
      client.get(api_path).map{|data| new(data) }
    else
      []
    end
  end

  private

  def self.client
    @client ||= Bittrex.client
  end

end
