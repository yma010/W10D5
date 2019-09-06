require 'json'
require 'byebug'
class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    found_cookie = req.cookies["_rails_lite_app"]
    # debugger
    if found_cookie
      @session_cookie = JSON.parse(found_cookie)
    else
      @session_cookie = {}
    end
  end

  def [](key) 
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = {path: "/", value: @session_cookie.to_json}
    res.set_cookie(:_rails_lite_app, cookie)
  end
end
