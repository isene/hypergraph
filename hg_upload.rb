#!/usr/bin/ruby
#encoding: utf-8

require "cgi"
require "erb"

begin
    File.delete("hypergraph_strict.hl")
rescue
end

begin
    File.delete("hypergraph.dot")
rescue
end

begin
    File.delete("hypergraph.png")
rescue
end

begin
    File.delete("hypergraph.hl")
rescue
end

cgi = CGI.new
@hl = cgi.params["upfile"][0].read
File.write("hypergraph.hl", @hl)

@s = "s"
@d = "d"
@a = "a"

@s = cgi["state"][0].downcase
@d = cgi["direction"][0].downcase
@a = cgi["arrow"][0].downcase
@o = @s + @d + @a

@x = %x{hypergraph -#{@o} hypergraph.hl}
tmpl = File.read("../hg_uploaded.html")

out = ERB.new(tmpl)

print "Content-type: text/html\n\n"
print out.result()
