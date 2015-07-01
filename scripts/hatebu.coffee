# Description:
#  はてブホットエントリーを表示
#
# Commands:
#   hubot hatebu
#
# Notes:
#

request = require 'request'
to_json = require('xmljson').to_json

module.exports = (robot) ->
  robot.respond /hatebu/i,  (msg) ->
    options =
      url: 'http://feeds.feedburner.com/hatena/b/hotentry'
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      to_json body,  (err,  data) =>
        text = "はてブ ホットエントリ\n"
        for id,  item of data["rdf:RDF"].item
          title = item.title
          link  = item.link
          text += "#{title} #{link}\n"
        msg.send(text)
