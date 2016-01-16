class RateLimitHandler
  LIMIT = 600

  def call(env)
    count = cache_incr(env)

    headers = { 'X-RateLimit-Limit' => LIMIT, 'X-RateLimit-Remaining' => [0, LIMIT - count].max }

    if count > LIMIT
      [403, { 'Content-Type' => 'text/plain' }.merge(headers), ['Forbidden']]
    else
      [399, headers, []]
    end
  end

  def cache
    @cache ||= Redis.new('localhost', 6379)
  end

  def cache_key(env)
    time = Time.now.utc
    [env['REMOTE_ADDR'], "#{time.year}-#{time.month}-#{time.day}-#{time.hour}"].join(':')
  end

  def cache_incr(env)
    key   = cache_key(env)
    count = cache.incr(key)
    cache.expire(key, 86400) if count == 1
    count
  end
end

RateLimitHandler.new
