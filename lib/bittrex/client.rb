class Bittrex::Client < Client

  def get(path, params = {}, headers = {})
    nonce = Time.now.to_i
    hash = cache_key(path ,params, headers)
    if cache[hash]
      puts "FROM CACHE #{hash}".white
      response = cache[hash]
    else
      query = params.merge(apikey: key, nonce:nonce).to_query
      url = "#{host}/#{path}?#{query}"
      response = connection.get do |req|
        req.url(url)
        if key
          req.params[:apikey] = key
          req.params[:nonce] = nonce
          req.headers[:apisign] = signature(url)
        end
      end
      puts "REQUEST #{hash}".blue
      cache[hash] = response
    end
    answer = JSON.parse(response.body)
    unless answer['success']
      raise "#{answer['message']}"
    end
    answer['result']
  end

  private

  def cache_key(path, params, headers)
    "#{path}-#{params}-#{headers}-#{time}"
  end

  def signature(url)
    OpenSSL::HMAC.hexdigest(digest = OpenSSL::Digest.new('sha512'), secret, url)
  end

  def host
    'https://bittrex.com/api/v1.1'
  end

end
