# Description:
#   rotate proxy.
#
# Commands:
#   hubot proxy_rotate {query: like jp, us....}
#

client  = require 'cheerio-httpcli'


module.exports = (robot) ->
  robot.respond /proxy_rotate( +([a-zA-Z]{2})( [0-9]+)?)$/i, (msg) ->
    url = 'http://www.cybersyndrome.net/search.cgi'
    q = msg.match[2].toUpperCase()
    addr_num = msg.match[3]
    client.fetch url, {'q': q}, (error, $, response, body) ->
      m = body.match(/^var as.*$/m)

      if !m
        msg.send "proxy not updated."
        return
        
      eval(m[0].split(";")[0])
      eval(m[0].split(";")[1])
      eval(m[0].split(";")[2])
      eval(m[0].split(";")[3])

      addrs = []
      for a, i in as
        idx = Math.floor(i/4)
        if i%4==0
          addrs[idx] = "http://" +a+"."
        else if i%4==3
          addrs[idx] += a + ":" + ps[idx] + "/"
        else
          addrs[idx] += a+"."

      if addrs.length > 0
        env_key = "HUBOT_#{q}_HTTP_PROXY"
        pos = 0
        if addr_num
          pos = parseInt(addr_num.trim(), 10)
        process.env[env_key] = addrs[pos]
        msg.send "proxy [#{env_key}] updated to [#{addrs[pos]}]."
      else
        msg.send "proxy not updated."
