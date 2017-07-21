# Description:
#   dominion randomizer
#
# Commands:
#   hubot dominion 基本 陰謀
#
# Notes:
#

request = require 'request'

PACKAGES =
  "基本": ["基本", "きほん", "きほｎ"]
  "陰謀": ["陰謀", "いんぼう"]
  "海辺": ["海辺", "うみべ"]
  "錬金術": ["錬金術", "れんきんじゅつ"]
  "繁栄": ["繁栄", "はんえい", "反映", "羽根井", "はねい", "羽井"]
  "収穫祭": ["収穫祭", "しゅうかくさい", "秋穫祭"]
  "異郷": ["異郷", "いきょう", "異教", "異境"]
  "暗黒時代": ["暗黒時代", "あんこくじだい", "暗黒", "あんこく", "アンコ食う"]
  "ギルド": ["ギルド", "ぎるど"]
  "冒険": ["冒険", "ぼうけん", "ぼうけｎ", "某県"]
  "帝国": ["帝国", "ていこく", "定刻", "帝國"]

ADDITIONAL_PACKAGES =
  "基本2": ["基本2", "基本２", "きほん２", "きほん2"]
  "陰謀2": ["陰謀2", "陰謀２", "いんぼう２", "いんぼう2"]

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

module.exports = (robot) ->
  robot.respond /dominion(.*)$/i, (msg) ->
    # パラメータから使用するパッケージを特定
    params = msg.match[1].split(/\s+/)
    use_packages = {}
    for key, names of PACKAGES
      for param in params
        for name in names
          if name == param
            use_packages[key] = true
    # 錬金術が明示されていればforce_alchemyフラグを立てる
    force_alchemy = 0
    if use_packages['錬金術']
      force_alchemy = 1
    # 何も指定されていなければ2nd拡張を除いて全てを対象にする
    if Object.keys(use_packages).length == 0
      for key, names of PACKAGES
        use_packages[key] = true

    options =
      url: "https://highemerly.net/dominion-api/api.json"
      method: 'POST'
      timeout: 2000
      json: true
      form: {
        set0: `use_packages['基本'] ? 1 : 0`
        set1: `use_packages['陰謀'] ? 1 : 0`
        set2: `use_packages['海辺'] ? 1 : 0`
        set3: `use_packages['錬金術'] ? 1 : 0`
        set4: `use_packages['繁栄'] ? 1 : 0`
        set5: `use_packages['収穫祭'] ? 1 : 0`
        set6: `use_packages['異郷'] ? 1 : 0`
        set7: `use_packages['暗黒時代'] ? 1 : 0`
        set8: `use_packages['ギルド'] ? 1 : 0`
        set9: `use_packages['冒険'] ? 1 : 0`
        set10: `use_packages['帝国'] ? 1 : 0`
        set0_2: '0'
        set1_2: '0'
        set100: '0'
        set101: '0'
        set102: '0'
        set103: '0'
        set104: '0'
        set105: '0'
        set106: '0'
        set107: '0'
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
      }
    request options,  (error,  response,  body) ->
      msg_array = ["https://highemerly.net/dominion/"]
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
        msg.send(msg_array.join('\n'))
