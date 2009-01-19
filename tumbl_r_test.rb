require 'tumbl_r'

def debug(obj, attr)
  value = obj.send(attr.to_sym)
  value = value[0..30] << '...' if value.is_a?(String) && value.length > 30
  puts "#{attr}: #{value.inspect} (#{value.class})"
end

# api = TumblR.new(:username => 'demo')
# api = TumblR.new(:url => 'http://tumbl.strelau.net')
blog = api.read
puts "BLOG (#{blog.class})"
debug blog, :username
debug blog, :url
debug blog, :title
debug blog, :subtitle
debug blog, :post_count
puts "posts: #{blog.posts.map{|p| p.type}.inspect}"

post = blog.posts.first
puts
puts "POST (#{post.class})"
debug post, :id
debug post, :permalink
debug post, :type
debug post, :timestamp

text = blog.posts.find {|p| p.type == 'text' }
puts
puts "TEXT POST (#{text.class})"
unless text.nil?
  debug text, :title
  debug text, :body
end

photo = blog.posts.find {|p| p.type == 'photo' }
puts
puts "PHOTO POST (#{photo.class})"
unless photo.nil?
  debug photo, :caption
  debug photo, :url
end

link = blog.posts.find {|p| p.type == 'link' }
puts
puts "LINK POST (#{link.class})"
unless link.nil?
  debug link, :text
  debug link, :url
  debug link, :description
end

conv = blog.posts.find {|p| p.type == 'conversation' }
puts
puts "CONV POST (#{conv.class})"
unless conv.nil?
  debug conv, :text
  puts "lines: #{conv.lines.map {|l| l.class }.inspect}"
  line = conv.lines.first
  debug line, :name
  debug line, :label
  debug line, :text
end

video = blog.posts.find {|p| p.type == 'video' }
puts
puts "VIDEO POST (#{video.class})"
unless video.nil?
  debug video, :caption
  debug video, :url
  debug video, :player
end

audio = blog.posts.find {|p| p.type == 'audio' }
puts
puts "AUDIO POST (#{audio.class})"
unless audio.nil?
  debug audio, :plays
  debug audio, :caption
  debug audio, :player
end
