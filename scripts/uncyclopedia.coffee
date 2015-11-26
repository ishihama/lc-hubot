# Description:
#  uncyclopedia
#
# Commands:
#   hubot uncyclopedia <query>
#
# Notes:
#

request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.respond /uncyclopedia (.+)$/i, (msg) ->
    options =
      url: "http://ja.uncyclopedia.info/api.php?action=parse&format=json&page=#{encodeURI(msg.match[1])}&prop=text&redirects=1"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      json = JSON.parse(body)
      if json.hasOwnProperty('error')
        msg.send(json['error']['info'])
        return
      title = (json['parse']['title'])
      article = (json['parse']['text']['*'])
      $ = cheerio.load article
      text = ""
      $('p:root').each () -> 
        text = "#{text}#{$(this).text()}"
        if (text.length > 100)
          return false
      msg.send("#{title}とは？\n#{text}")
