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
          channelId: res.message.rawMessage.channel
          userId: res.message.user.id
          date: new Date()
        , (err, resp) ->
          if err
            res.send err

  robot.respond /search (all )?(.+)/i, (res) ->
    query = res.match[2]
    mentions = utils.extractMentions res.message.rawText
    allRooms = res.match[1]?

    # Ensure we do not include params in query
    query = query.replace "/<[^ ]>/", ''

    query =
      bool:
        must: [
          { match: { message: query } }
        ]

    if not allRooms
      if mentions.channels.length
        query.bool.must.push { match: { channelId: mentions.channels.join(' ') } }
      else
        query.bool.must.push { match: { channelId: res.message.rawMessage.channel } }

    if mentions.users.length
      query.bool.must.push { match: { userId: mentions.users.join(' ') } }
    else
      query.bool.must.push { match: { userId: res.message.user.id } }

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
          formattedDate = moment(date).format('MMM D YY, h:mm:ss a')
          room = hit._source.room

          out += "[##{room}][#{formattedDate}] #{hit._source.user}: #{hit.highlight.message[0]}\n"

        if not out
          out = 'Found nothing!'
        res.send out
