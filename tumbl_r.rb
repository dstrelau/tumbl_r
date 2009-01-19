#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'
require 'open-uri'

class Object
  def try(method)
    self.send(method)
  end
end

class NilClass
  def try(method)
    nil
  end
end

class TumblR

  def initialize(options={})
    @username = options[:username]
    @url = options[:url]
  end

  def read
    url = @url || "http://#{@username}.tumblr.com"
    Blog.new(open("#{url}/api/read") { |f| Hpricot(f) })
  end

  class Blog
    attr_reader :xml
    def initialize(xml)
      @xml = xml
    end

    def username
      @xml.at(:tumblelog)[:name]
    end

    def url
      @xml.at(:tumblelog)[:cname]
    end

    def title
      @xml.at(:tumblelog)[:title]
    end

    def subtitle
      @xml.at(:tumblelog).try(:inner_text)
    end

    def posts
      @xml.search(:post).map {|xml| Post.create(xml) }
    end

    def post_count
      @xml.at(:posts)[:total].to_i
    end

    def inspect
      super #TODO
    end
  end

  class Post
    attr_reader :xml
    def initialize(xml)
      @xml = xml
    end

    def id
      @xml[:id].to_i
    end

    def permalink
      URI.parse @xml[:url]
    end

    def tumblr_type
      @xml[:type]
    end
    private :tumblr_type

    def type
      tumblr_type == 'regular' ? 'text' : tumblr_type
    end

    def timestamp
      Time.at(@xml['unix-timestamp'].to_i)
    end

    def inspect
      super #TODO
    end

    def self.create(xml)
      case xml[:type]
      when 'regular'      then TextPost.new(xml)
      when 'photo'        then PhotoPost.new(xml)
      when 'quote'        then QuotePost.new(xml)
      when 'link'         then LinkPost.new(xml)
      when 'conversation' then ConversationPost.new(xml)
      when 'audio'        then AudioPost.new(xml)
      when 'video'        then VideoPost.new(xml)
      else self.new(xml)
      end
    end

    private
    def self.attribute(name)
      define_method(name.to_sym) do
        @xml.at("#{tumblr_type}-#{name}").try(:inner_text)
      end
    end
  end

  class TextPost < Post
    attribute :title
    attribute :body
  end

  class PhotoPost < Post
    attribute :caption

    def url(opts = {:width => 500})
      raise ArgumentError unless [500, 400, 250, 100, 75].include?(opts[:width])
      url = @xml.at("photo-url[@max-width='#{opts[:width]}']").try(:inner_text)
      URI.parse(url) unless url.nil?
    end
  end

  class QuotePost < Post
    attribute :text
    attribute :source
  end

  class LinkPost < Post
    attribute :text
    attribute :description
    def url
      url = @xml.at('link-url').try(:inner_text)
      begin
        URI.parse(url)
      rescue URI::InvalidURIError
        nil
      end
    end
  end

  class ConversationPost < Post
    attribute :text
    def lines
      @xml.search(:line).map {|xml| Line.new(xml) }
    end

    class Line
      attr_reader :xml
      def initialize(xml)
        @xml = xml
      end

      def name
        @xml[:name]
      end

      def label
        @xml[:label]
      end

      def text
        @xml.inner_text
      end
    end
    
  end

  class AudioPost < Post
    attribute :caption
    attribute :player
    def plays
      @xml['audio-plays'].to_i
    end
  end

  class VideoPost < Post
    attribute :caption
    attribute :player
    def url
      url = @xml.at('video-source').try(:inner_text)
      begin
        URI.parse(url)
      rescue URI::InvalidURIError
        nil
      end
    end
  end

end
