# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot fb interrupt
#
# Notes:
#
# Author:
#   benrudolph

config = require('config')
_ = require('lodash')
request = require('request')
parseString = require('xml2js').parseString
fbUrl = 'http://manage.dimagi.com'
interruptFilter = 570

module.exports = (robot) ->

  robot.respond /fb interrupt/i, (res) ->
    request
      .get(
        {
          url: fbBaseUrl(),
          qs: {
            cmd: 'setCurrentFilter'
            sFilter: 'interruptFilter'
          }
        }, (err, response, body) ->
          if err
            res.send err
            return

          request
            .get(
              {
                url: fbBaseUrl()
                qs: {
                  cmd: 'search'
                  cols: 'sTitle,sPersonAssignedTo'
                }
              }, (err, response, body) ->
                parseString body, (err, result) ->
                  cases = result.response.cases[0].case
                  out = ''
                  _.each cases, (c) ->
                    # HTML links are broken, so need to use raw link
                    # https://github.com/slackhq/hubot-slack/issues/114
                    out += "#{fbUrl}/default.asp?#{c['$'].ixBug}: #{c.sPersonAssignedTo}\n"

                  res.send out
            )
      )


fbBaseUrl = ->
  apiKey = config.get 'FogBugz.key'

  "#{fbUrl}/api.asp?token=#{apiKey}"
