# Description:
#   enjoy curry. (powered by hotpepper webapi)
#
# Commands:
#   hubot curry {areaName}
#

request = require 'request'

if proxy = process.env.HUBOT_TABELOG_PROXY
  console.log 'proxy: ' + proxy
  request = request.defaults {'proxy': proxy}

module.exports = (robot) ->
  robot.respond /curry( (.*))/i, (msg) ->
    # getting areacode
    small_area_q = 
      "key": process.env.WEBSERVICE_RECRUIT_APIKEY,
      "keyword": msg.match[2],
      "format": "json"
    request
      url: "http://webservice.recruit.co.jp/hotpepper/small_area/v1/",
      qs: small_area_q,
      (err, res, body) ->
        s_area_codes = ""
        for s_area in JSON.parse(body).results.small_area
          s_area_codes += "," + s_area.code

        # getting shops
        gourmet_q = 
          "key": process.env.WEBSERVICE_RECRUIT_APIKEY,
          "keyword": "インド",
          "genre": "G009,G010",
          "small_area": s_area_codes,
          "format": "json"
        request
          url: "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/",
          qs: gourmet_q,
          (err, res, body) ->
            shops = JSON.parse(body).results.shop
            shop = msg.random shops
            text = "見つかりませんでした・・・"
            if shop
              text = "#{shop.name}\n  #{shop.address}\n  #{shop.photo.pc.m}\n  #{shop.urls.pc}"
            msg.send text
