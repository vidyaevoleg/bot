class Poloniex::Client < MainClient

  def res(request_type, path, command, params={}, headers={})

    nonce = (Time.now.to_f * 10000000).to_i
    params[:nonce] = nonce
    params[:command] = command

    url = "#{host}/#{path}"
    hash = cache_key(path, params.except(:nonce))

    result = Rails.cache.fetch(hash) do
      if request_type == :post
        response = connection.post do |req|
          req.url(url)
          req.body = params
          req.headers[:Key] = key
          req.headers[:Sign] = signature(params)
          req.headers.merge!(headers)
        end
      else
        response = connection.get do |req|
          req.url(url)
          req.params.merge!(params)
          req.headers[:Key] = key
          req.headers[:Sign] = signature(params)
          req.headers.merge!(headers)
        end

      end
      puts "REQUEST #{hash}".blue
      response
    end

    answer = JSON.parse(result.body)

    raise "#{answer['error']}" if !answer.is_a?(Array) && answer['error']
    answer
  end

  def post(*args)
    res(:post, *args)
  end

  def get(*args)
    res(:get, *args)
  end

  private

  def cache_key(path, params)
    "#{path}-#{params}-#{time}"
  end

  def signature(params)
    OpenSSL::HMAC.hexdigest(digest = OpenSSL::Digest.new('sha512'), secret, params.to_query)
  end

  def host
    'https://poloniex.com'
  end

end
