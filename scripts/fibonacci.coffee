# Description:
#   Fibonacci
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot fibonacci N - get fibonacci N

module.exports = (robot) ->
  robot.respond /fibonacci( (\d+))/i, (msg) ->
    prev = 0
    curr = 1
    str = "" + prev
    if parseInt(msg.match[2]) > 0
      for i in [1..parseInt(msg.match[2])]
        fib = prev + curr
        prev = curr
        curr = fib
        str += ", " + fib
    msg.send str

