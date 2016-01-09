expect = require('chai').expect
utils = require('../utils/utils')

describe 'Igor Search', ->
  describe 'Utils', ->
    it 'should correctly extract mentions', ->
      mentions = utils.extractMentions 'igor search <@1234> <#C32A> my query'
      expect(mentions.users).to.eql mentions.users, ['C32A']
      expect(mentions.channels).to.eql mentions.channels, ['1234']
