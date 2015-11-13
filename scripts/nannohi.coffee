# Description:
#   What a lovery day!
#   get Holiday from Wikipedia.
#
# Commands:
#   hubot なんの日
#   hubot 何の日
#

request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.respond /(なんの日|何の日)/i, (msg) ->
    date = new Date
    todayText = (date.getMonth()+1) + "月" + date.getDate() + "日"
    request 'https://ja.wikipedia.org/wiki/' + encodeURIComponent(todayText), (error, response, body) ->
      $ = cheerio.load body
      elm = $("h2:has(span:contains('記念日・年中行事'))").next()
      lists = []
      while(elm[0].name != "h2")
        $("li", elm).each () ->
          fulltext = $(this).text().split(/(\r\n|\r|\n)/)
          nannohi = 
            "title": fulltext[0].replace("（ ", "（")
            "description": fulltext[4]
          lists.push nannohi
        elm = elm.next()
      nannohi = lists[Math.floor(Math.random() * lists.length)]
      msg.send nannohi.title
      msg.send "    " + nannohi.description
