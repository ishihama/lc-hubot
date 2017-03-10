request = require 'request'
cheerio = require 'cheerio'
iconv = require "iconv"
buffer = require "buffer"

module.exports = (robot) ->
  robot.respond /game (.+)$/i, (msg) ->
    options =
      url: "http://kakaku.com/game/release/Date=201703/"
      encoding:"binary"
      timeout: 5000
      headers: {'user-agent': 'node fetcher'}
    request options,  (error,  response,  body) ->
      request_title = msg.match[1]
      conv = new iconv.Iconv('SJIS', 'UTF-8//TRANSLIT//IGNORE')
      body = new Buffer(body, 'binary')
      body = conv.convert(body).toString()
      $ = cheerio.load body
      release_day = ""
      flag = 0
      $("#titleSche tr").each () ->
        if ($('.weekly', this).length)
          release_day = $('.weekly', this).text()

        title = $('.gameTitle a', this).text()
        if (title.match(request_title))
          flag = 1
          msg.send(title + "  の発売日は " + release_day)

      if (!flag)
        msg.send("また発売はだいぶ先みたいっす")

      msg.send("とりあえず3月の分しか対応してませんヽ(=´▽`=)ﾉ")
