# Description:
#  one_night_jinro
#
# Commands:
#  hubot one_night_jinro <@{member}> <@{member}> <@{member}>
#
# Notes:
#
cronJob = require('cron').CronJob

GAME_START_MSG = "このメンバーでワードウルフを始めます。"
COUTNDOUN_START_MSG = "これから５分間でワードウルフを探し出してください！カウントダウンを開始します。"
LAST_MIN_MSG = "残り１分です。"
TIME_LIMIT_MSG = "終了です。答え合わせを行ってください。"
FRUIT_LIST = ["りんご","いちご","さくらんぼ","青りんご","なし","みかん","ぶどう","バナナ","マスカット","スイカ","メロン","ブルーベリー","パイナップル"]

module.exports = (robot) ->
  robot.respond /(wordwolf|ワード人狼)(.*)$/i, (msg) ->
    # 呼び出された部屋のメンバーを取得する
    users = robot.brain.data.users
    # 呼び出した人は参加者に追加
    members = [msg.message.user.name]
    # メンションされたメンバーが存在する場合は参加者に追加
    for str, i in msg.match[2].split(' ')
      name = str.replace('@','')trim()
      for user, j in users
        roomMembers.push user.name if name.toLowerCase() == users.name.toLowerCase()
    # 開始メッセージを送る
    robot.send {room: members}, GAME_START_MSG
    # ワード抽選
    word_1 = msg.random(FRUIT_LIST)
    word_2 = msg.random(FRUIT_LIST.remove(word_1))
    # ワード１を誰かに割り振り、DMで送る
    wordwolf = msg.random(members)
    robot.send {room: wordwolf}, word_1

    # ワード２をその他全員に割り振り、DMで送る
    for member in members
      robot.send {room: member}, word_2 if member != wordwolf

    # カウントダウン用のメッセージを登録
    robot.send {room: members}, COUTNDOUN_START_MSG
