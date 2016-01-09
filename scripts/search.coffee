# Description
#   Runs Fogbugz utilities
#
# Dependencies:
#
# Configuration:
#   NODE_ENV=(local|production)
#
# Commands:
#   hubot search <all> <user=[username]> <room=[room]> <query> - searches for a message
#
# Notes:
#
# Author:
#   benrudolph

elasticsearch = require 'elasticsearch'
_ = require 'lodash'
moment = require 'moment'
utils = require '../utils/utils'

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
            res.send err

  robot.respond /search (all )?(.+)/i, (res) ->
    query = res.match[2]
    allRooms = res.match[1]?

    user = utils.extractUser query
    room = utils.extractRoom(query) || res.message.room

    query =
      bool:
        must: [
          { match: { message: query } }
        ]

    if not allRooms
      query.bool.must.push { match: { room: room } }
    if user
      query.bool.must.push { match: { user: user } }

    client.search
      index: INDEX
      type: MESSAGE_TYPE
      body:
        query: query
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
          date = new Date hit._source.date
          formattedDate = moment(date).fromNow()

          out += "[#{formattedDate}] #{hit._source.user}: #{hit.highlight.message[0]}\n"

        if not out
          out = 'Found nothing!'
        res.send out
