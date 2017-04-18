# Description:
#   rotate proxy.
#
# Commands:
#   hubot proxy_rotate {query: like jp, us....}
#

client  = require 'cheerio-httpcli'


module.exports = (robot) ->
  robot.respond /proxy_rotate( +([a-zA-Z]{2}))$/i, (msg) ->
    url = 'http://www.cybersyndrome.net/search.cgi'
    q = msg.match[2].toUpperCase()
    client.fetch url, {'q': msg.match[2]}, (error, $, response, body) ->
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
        process.env[env_key] = addrs[0]
        msg.send "proxy [#{env_key}] updated to [#{addrs[0]}]."
      else
        msg.send "proxy not updated."
