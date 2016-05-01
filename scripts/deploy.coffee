# Description
#   Deploy utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot deploy <env> - Initiates a deploy to <env>
#   hubot deploy status - Lists statuses of all current deploys
#   hubot deploy previous - Lists statuses of all previous deploys
#
# Notes:
#
# Author:
#   benrudolph

CAPTAIN_URL = 'http://localhost:8000'

request = require('request')

module.exports = (robot) ->

  robot.respond /deploy ([\w]+)/i, (res) ->
    env = res.match[1]
    codeBranch = 'master'
    user = res.message.user.name
    if env == 'staging'
      codeBranch = 'autostaging'

    data =
      env: env
      code_branch: codeBranch
      deploy_user: user

    request.post(CAPTAIN_URL + '/deploy/', formData: data, (err, response, body) ->
      if err || response.statusCode >= 400
        res.send "Failed to deploy deploy to #{env} on #{codeBranch} by #{user}"
      else
        res.send "Successfully initiated deploy to #{env} on #{codeBranch} by #{user}"
    )



