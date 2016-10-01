require 'nokogiri'

module Jekyll
  module TocFilter
    def apply_toc(html)
      document = Nokogiri::HTML.fragment(html)
      toc = "<nav class='toc'><span class='title'>Table of contents</span>"
      i = 0
      prev = 0
      curr = 0
      highest = 0

      # add toc ids to all headings
      document.css("h1,h2,h3,h4,h5,h6,h7").each do |heading|
        # TODO: make this add instead of overwrite
        heading["id"] = "toc-#{i}"

        prev = curr
        curr = Integer(heading.name[1])

        if curr > highest
          highest = curr
        end

        if curr < prev
          toc += "</ul>\n"
        end

        if curr > prev
          toc += "<ul class='#{curr}'>\n"
        end

        toc += "<li><a href='##{heading["id"]}'>#{heading.text}</a></li>\n"

        # increment the counter
        i += 1
      end

      while highest > 1
        toc += "</ul>"
        highest -= 1
      end

      toc += "</nav>"

      return toc + document.to_html
    end
  end
end

Liquid::Template.register_filter(Jekyll::TocFilter)

