# Description:
#   get trends from Google Trends
#
# Commands:
#   hubot trends {Country_code by 2chars (jp, us, in......)}.
#   hubot trends help - for lookup country codes.
#

request = require 'request'

regions =
  "jp":
    "code": "4",
    "name": "日本",
  "us":
    "code": "1",
    "name": "アメリカ合衆国",
  "ar":
    "code": "30",
    "name": "アルゼンチン",
  "gb":
    "code": "9",
    "name": "イギリス",
  "il":
    "code": "6",
    "name": "イスラエル",
  "it":
    "code": "27",
    "name": "イタリア",
  "in":
    "code": "3",
    "name": "インド",
  "id":
    "code": "19",
    "name": "インドネシア",
  "ua":
    "code": "35",
    "name": "ウクライナ",
  "eg":
    "code": "29",
    "name": "エジプト",
  "au":
    "code": "8",
    "name": "オーストラリア",
  "at":
    "code": "44",
    "name": "オーストリア",
  "nl":
    "code": "17",
    "name": "オランダ",
  "ca":
    "code": "13",
    "name": "カナダ",
  "gr":
    "code": "48",
    "name": "ギリシャ",
  "ke":
    "code": "37",
    "name": "ケニア",
  "co":
    "code": "32",
    "name": "コロンビア",
  "sa":
    "code": "36",
    "name": "サウジアラビア",
  "sg":
    "code": "5",
    "name": "シンガポール",
  "ch":
    "code": "46",
    "name": "スイス",
  "se":
    "code": "42",
    "name": "スウェーデン",
  "es":
    "code": "26",
    "name": "スペイン",
  "th":
    "code": "33",
    "name": "タイ",
  "cz":
    "code": "43",
    "name": "チェコ共和国",
  "cl":
    "code": "38",
    "name": "チリ",
  "dk":
    "code": "49",
    "name": "デンマーク",
  "de":
    "code": "15",
    "name": "ドイツ",
  "tr":
    "code": "24",
    "name": "トルコ",
  "ng":
    "code": "52",
    "name": "ナイジェリア",
  "no":
    "code": "51",
    "name": "ノルウェー",
  "hu":
    "code": "45",
    "name": "ハンガリー",
  "ph":
    "code": "25",
    "name": "フィリピン",
  "fi":
    "code": "50",
    "name": "フィンランド",
  "br":
    "code": "18",
    "name": "ブラジル",
  "fr":
    "code": "16",
    "name": "フランス",
  "vn":
    "code": "28",
    "name": "ベトナム",
  "be":
    "code": "41",
    "name": "ベルギー",
  "pl":
    "code": "31",
    "name": "ポーランド",
  "pt":
    "code": "47",
    "name": "ポルトガル",
  "my":
    "code": "34",
    "name": "マレーシア",
  "mx":
    "code": "21",
    "name": "メキシコ",
  "ro":
    "code": "39",
    "name": "ルーマニア",
  "ru":
    "code": "14",
    "name": "ロシア",
  "hk":
    "code": "10",
    "name": "香港",
  "tw":
    "code": "12",
    "name": "台湾",
  "kr":
    "code": "23",
    "name": "大韓民国",
  "za":
    "code": "40",
    "name": "南アフリカ"


getRegion = (id, regions) ->
  for rid, region of regions
    return region if id.toLowerCase() is rid.toLowerCase()


module.exports = (robot) ->
  robot.respond /trends( ([a-zA-Z]{2}))/i, (msg) ->
    region = getRegion(msg.match[2], regions)
    options =
      url: 'http://www.google.com/trends/hottrends/hotItems'
      timeout: 2000
      headers: {'user-agent': 'node fetcher'}
      form:
        ajax: '1'
        pn:   'p' + region.code
        htd:  ''
        htv:  'l'
    text = region.name + 'のトレンド'
    request.post options, (error, response, body) ->
      trendsByDate = JSON.parse(body).trendsByDateList[0]
      i = 1
      for trends in trendsByDate.trendsList
        text += '\n' + (i++) + ': ' + trends.title
      msg.send text

  robot.respond /trends help/i, (msg) ->
    text = ''
    for rid, region of regions
      text += '\n' + rid + ': ' + region.name
    msg.send text

