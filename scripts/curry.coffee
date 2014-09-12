# Description:
#   enjoy curry. (powered by hotpepper webapi)
#
# Commands:
#   hubot curry {areaName}
#

module.exports = (robot) ->
  robot.respond /curry( (.*))/i, (msg) ->
    # getting areacode
    small_area_q = 
      "key": process.env.WEBSERVICE_RECRUIT_APIKEY,
      "keyword": msg.match[2],
      "format": "json"
    msg.http "http://webservice.recruit.co.jp/hotpepper/small_area/v1/"
      .query(small_area_q)
      .get() (err, res, body) ->
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
        msg.http "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
          .query(gourmet_q)
          .get() (err, res, body) ->
            shops = JSON.parse(body).results.shop
            shop = msg.random shops
            text = "見つかりませんでした・・・"
            if shop
              text = "#{shop.name}\n  #{shop.address}\n  #{shop.photo.pc.m}\n  #{shop.urls.pc}"
            msg.send text
