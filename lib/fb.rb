# frozen_string_literal: true

require_relative "fb/version"

require 'net/http'
require 'json'

require_relative "fb/config"
require_relative "fb/http_request"

module Fb
  class Error < StandardError; end

  class User
    def initialize(options = {})
      @access_token = options[:access_token]
    end

    def email
      @email ||= begin
        request = HTTPRequest.new path: '/me', params: {
          fields: :email,
          access_token: @access_token
        }
        request.run.body['email']
      end
    end

    def pages
      @pages ||= begin
        params = { access_token: @access_token }
        request = HTTPRequest.new path: '/me/accounts', params: params
        request.run.body['data'].map do |page_data|
          Page.new symbolize_keys(page_data.merge access_token: @access_token)
        end
      end
    end

    def revoke_permissions
      params = { access_token: @access_token }
      request = HTTPRequest.new path: '/me/permissions', params: params, method: :delete
      request.run.body['success']
    end

    private

    def symbolize_keys(hash)
      {}.tap do |new_hash|
        hash.each_key{|key| new_hash[key.to_sym] = hash[key]}
      end
    end
  end

  class Page
    attr_reader :id, :name, :category

    def initialize(options = {})
      @id = options[:id]
      @name = options[:name]
      @category = options[:category]
      @access_token = options[:access_token]
    end
  end
end
