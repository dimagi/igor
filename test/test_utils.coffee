expect = require('chai').expect
utils = require('../utils/utils')

describe 'Igor Search', ->
  describe 'Utils', ->
    it 'should correctly extract mentions', ->
      mentions = utils.extractMentions 'igor search <@1234> <#C32A> my query'
      expect(mentions.users).to.eql ['1234']
      expect(mentions.channels).to.eql ['C32A']

    it 'should correctly remove channels', ->
      query = utils.removeChannelsFromQuery '#field-dev dead'
      expect(query).to.eql 'dead'

      query = utils.removeChannelsFromQuery 'alive #field-dev dead'
      expect(query).to.eql 'alive dead'

      query = utils.removeChannelsFromQuery 'alive dead #field-dev'
      expect(query).to.eql 'alive dead'

    it 'should correctly remove users', ->
      query = utils.removeUsersFromQuery '@benrudolph dead'
      expect(query).to.eql 'dead'

      query = utils.removeUsersFromQuery 'alive @benrudolph dead'
      expect(query).to.eql 'alive dead'

      query = utils.removeUsersFromQuery 'alive dead @benrudolph'
      expect(query).to.eql 'alive dead'
