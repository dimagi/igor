# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot fb interrupt - Lists all tickets assigned to interrupt
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
neglectedFilter = 525

module.exports = (robot) ->
  robot.respond /fb filter ([0-9]+)/i, (res) ->
    filterId = res.match[1]
    fbCasesByFilter filterId, (response)->
      out = formatCaseXML response
      res.send out

  robot.respond /fb neglected/i, (res) ->
    fbCasesByFilter neglectedFilter, (response)->
      out = formatCaseXML response
      res.send out

  robot.respond /fb interrupt/i, (res) ->
    fbCasesByFilter interruptFilter, (response)->
      out = formatCaseXML response
      res.send out

fbBaseUrl = ->
  apiKey = config.get 'FogBugz.key'

  "#{fbUrl}/api.asp?token=#{apiKey}"

fbCasesByFilter = (filterId, callback) ->
    request
      .get(
        {
          url: fbBaseUrl(),
          qs: {
            cmd: 'setCurrentFilter'
            sFilter: filterId
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
                  callback result.response
            )
      )

formatCaseXML = (xmlResponse) ->
    cases = xmlResponse.cases[0].case
    out = ''
    _.each cases, (c) ->
      # HTML links are broken, so need to use raw link
      # https://github.com/slackhq/hubot-slack/issues/114
      out += "#{fbUrl}/default.asp?#{c['$'].ixBug}: #{c.sPersonAssignedTo}\n"
    out
