# Description:
#   dominion randomizer
#
# Commands:
#   hubot dominion 基本 陰謀
#   hubot dominion help
#
# Notes:
#

request = require 'request'

PACKAGES =
  "set0": ["基本", "きほん", "きほｎ"]
  "set1": ["陰謀", "いんぼう"]
  "set2": ["海辺", "うみべ"]
  "set3": ["錬金術", "れんきんじゅつ"]
  "set4": ["繁栄", "はんえい", "反映", "羽根井", "はねい", "羽井"]
  "set5": ["収穫祭", "しゅうかくさい", "秋穫祭"]
  "set6": ["異郷", "いきょう", "異教", "異境"]
  "set7": ["暗黒時代", "あんこくじだい", "暗黒", "あんこく", "アンコ食う"]
  "set8": ["ギルド", "ぎるど"]
  "set9": ["冒険", "ぼうけん", "ぼうけｎ", "某県"]
  "set10": ["帝国", "ていこく", "定刻", "帝國"]

ADDITIONAL_PACKAGES =
  "set0_2": ["基本2nd", "基本2", "基本２", "きほん２", "きほん2"]
  "set1_2": ["陰謀2nd", "陰謀2", "陰謀２", "いんぼう２", "いんぼう2"]

PROMOTION_CARDS =
  "set100": ["闇市場", "やみいちば"]
  "set101": ["公使", "こうし", "講師", "行使", "格子", "公私", "光子", "子牛", "仔牛", "公司"]
  "set102": ["へそくり", "ヘソクリ"]
  "set103": ["囲郭村", "いかくそん", "威嚇損"]
  "set104": ["総督", "そうとく"]
  "set105": ["王子", "おうじ", "応じ", "皇子"]
  "set106": ["召還", "しょうかん", "しょうかｎ", "召喚"]
  "set107": ["サウナ/アヴァント", "サウナ", "アヴァント", "さうな", "あゔぁんと"]


CARD_CATEGORYS =
  kingdoms: "サプライ",
  prosperity: "白金貨/植民地(繁栄)",
  banes: "災い(収穫祭)",
  ruins: "廃墟(暗黒時代)",
  shelters: "避難所(暗黒時代)",
  treasures: "褒賞(収穫祭)",
  travelers: "トラベラー(冒険)",
  events: "イベント(冒険/帝国)",
  landmarks: "ランドマーク(帝国)",
  obelisk: "[再掲]オベリスクのアクションカード(帝国)",
  blackmarkets: "闇市場デッキ(プロモ)",
  others: "その他"

GAME_OPTIONS =
  portion: "ポーション",
  platinum: "白金貨",
  colony: "植民地",
  shelter: "避難所",
  ruins: "廃墟",
  bane: "災い",
  treasure: "褒賞",
  tokens: {
    vp: "勝利点トークン",
    coin: "コイントークン",
    embargo: "抑留トークン",
    travel: "旅トークン",
    trashing: "廃棄トークン",
    estate: "屋敷トークン",
    square: "四角トークン",
    round: "丸トークン",
    debt: "負債トークン",
  },
  mats: {
    traderoute: "交易路マット",
    island: "島マット",
    nativevillage: "原住民の村マット",
    pirateship: "海賊船マット",
    tavern: "酒場マット",
  },


WEBPARAM_CARD_LIST =
  kingdoms: "k",
  prosperity: "pr",
  banes: "ba",
  # ruins: "",
  shelters: "sh",
  # treasures: "",
  # travelers: "",
  events: "ev",
  landmarks: "la",
  obelisk: "ob",
  blackmarkets: "bm",


selectPackages = (packages, params) ->
  package_settings = {}
  for key, names of packages
    for param in params
      for name in names
        if name == param
          package_settings[key] = 1
  return package_settings

outputHelp = (msg) ->
  messages = ["以下から利用するパッケージ、プロモカードを指定してください"]
  messages.push "パッケージの指定がない場合は2ndを除外したすべての拡張から選択します"
  messages.push "-------- 基本・拡張パックの指定 --------"
  package_names = []
  for key, value of PACKAGES
    package_names.push value[0]
  for key, value of ADDITIONAL_PACKAGES
    package_names.push value[0]

  messages.push package_names.join(', ')
  messages.push "-------- プロモカードの指定 --------"
  promotion_names = []
  for key, value of PROMOTION_CARDS
    promotion_names.push value[0]

  messages.push promotion_names.join(', ')
  msg.send messages.join("\n")


module.exports = (robot) ->
  robot.respond /dominion(.*)$/i, (msg) ->
    if msg.match[1].trim() == "help"
      outputHelp(msg)
      return
    # パラメータから使用するパッケージを特定
    params = msg.match[1].split(/\s+/)
    package_settings = {}
    package_settings = Object.assign(package_settings, selectPackages(PACKAGES, params))
    package_settings = Object.assign(package_settings, selectPackages(ADDITIONAL_PACKAGES, params))
    # 錬金術が明示されていればforce_alchemyフラグを立てる
    force_alchemy = 0
    if package_settings['set3']
      force_alchemy = 1
    # 何も指定されていなければ2nd拡張を除いて全てを対象にする
    if Object.keys(package_settings).length == 0
      for key, names of PACKAGES
        package_settings[key] = 1
    package_settings = Object.assign(package_settings, selectPackages(PROMOTION_CARDS, params))

    form_base =
      settings_beginner: '0'
      settings_no_token: '0'
      settings_no_mat: '0'
      settings_no_attack: '0'
      settings_no_curse: '0'
      settings_no_weight_alchemy: '0'
      settings_force_alchemy: force_alchemy
      settings_weight_event: '0'
      settings_event_more_three: '0'
      settings_weight_landmark: '0'
      settings_landmark_more_three: '0'
      settings_no_only_first_edition: '0'
      order_by_cost: '0'
      order_by_pack: '1'
      max_cost: '100'

    options =
      url: "https://highemerly.net/dominion-api/api.json"
      method: 'POST'
      timeout: 2000
      json: true
      form: Object.assign(form_base, package_settings)
    request options,  (error,  response,  body) ->
      msg_array = []
      web_param = {}
      if !error && response.statusCode == 200
        for key, value of CARD_CATEGORYS
          if body.cardlists[key]
            msg_array.push "-------- #{value} --------"
            for card in body.cardlists[key]
              # 拡張名を取得
              if card.set
                card_name = "#{card.set.japanease}: #{card.name.japanease}"
              else
                card_name = "#{card.name.japanease}"
              
              # コストを取得
              if card.cost
                costs = []
                for cost_type in ["money", "portion", "debt"]
                  if card.cost[cost_type]
                    costs.push "#{card.cost[cost_type]}#{cost_type.substring(0,1)}"
                if costs.length > 0
                  card_name += " (#{costs.join(', ')})"
              web_param[WEBPARAM_CARD_LIST[key]] = (web_param[WEBPARAM_CARD_LIST[key]] or [])
              web_param[WEBPARAM_CARD_LIST[key]].push card.pile.number
              
              msg_array.push(card_name)
        
        # 必要になるオプションを特定(tokensとmatsは階層になってる)
        opt_array = []
        for key, value of GAME_OPTIONS
          if typeof(value) == "string"
            if body.options[key] == 1
              opt_array.push "#{value}"
          else
            for _key, _value of GAME_OPTIONS[key]
              if body.options[key][_key] == 1
                opt_array.push "#{_value}"
        if opt_array.length > 0
          msg_array.push "======== 利用オプション ========"
          msg_array = msg_array.concat opt_array

        # 改行でjoinしてメッセージ送信
        card_url = 'https://highemerly.net/dominion/card.html'
        query_params = []
        for key, value of web_param
          query_params.push "#{key}=#{value.join(',')}"

        msg_array.push "#{card_url}?#{query_params.join('&')}"
        msg.send(msg_array.join('\n'))
