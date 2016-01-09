# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot search <query> - searches for a message
#
# Notes:
#
# Author:
#   benrudolph

elasticsearch = require 'elasticsearch'
_ = require 'lodash'

INDEX = 'slack_messages'
MESSAGE_TYPE = 'message'

client = new elasticsearch.Client
  host: 'localhost:9200'

module.exports = (robot) ->
  robot.hear /.*/i, (res) ->
    if not _.startsWith res.message.text, 'igor'
      client.index
        index: INDEX
        type: MESSAGE_TYPE
        body:
          message: res.message.text
          user: res.message.user.name
          room: res.message.room
          date: new Date()
        , (err, resp) ->
          if err
            console.log err
          console.log resp

  robot.respond /search (.*)/i, (res) ->
    query = res.match[1]

    client.search
      index: INDEX
      type: MESSAGE_TYPE
      body:
        query:
          match:
            message: query
        highlight:
          pre_tags: ['*']
          post_tags: ['*']
          fields:
            message: {}
      , (err, resp) ->
        if err
          res.send err
          return

        out = ''
        _.each resp.hits.hits, (hit) ->
          out += hit.highlight.message[0] + '\n'
        res.send out
