# Description:
#   get funny image from irasutoya.
#
# Commands:
#   hubot irasuto
#

client  = require 'cheerio-httpcli'

module.exports = (robot) ->
  robot.respond /irasuto/i, (msg) ->
    client.fetch 'http://www.irasutoya.com/feeds/posts/summary?max-results=0&alt=json', {}, (error, $, response, body) ->
      total = parseInt(JSON.parse(body).feed.openSearch$totalResults.$t, 10)
      rnd = Math.floor(Math.random()*total)+1
      client.fetch 'http://www.irasutoya.com/feeds/posts/summary?start-index=' + rnd + '&max-results=1&alt=json', {}, (error, $, response, body) ->
        for link, i in JSON.parse(body).feed.entry[0].link
          if link.rel == "alternate"
            client.fetch link.href, {}, (error, $, response) ->
              m = $('div.entry img').attr('src')
              m += '\n' + link.title
              msg.send m

