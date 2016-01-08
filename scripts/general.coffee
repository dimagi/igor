module.exports = (robot) ->

  robot.hear /.*thank.*igor/i, (res) ->
    res.send "No problem #{res.message.user.name}. You're pretty clever yourself."
