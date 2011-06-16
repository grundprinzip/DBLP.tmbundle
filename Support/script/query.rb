SUPPORT = ENV['TM_SUPPORT_PATH']

require SUPPORT + '/lib/escape'
require SUPPORT + '/lib/exit_codes'
require SUPPORT + '/lib/osx/plist'

require 'net/http'
require 'rubygems'
begin
  require 'ajson'
rescue LoadError => e
  require ENV['TM_BUNDLE_SUPPORT'] + '/script/lib/json'
end
require 'ostruct'

class DBLPQuery

  BASE_URI = "http://dblp.mpi-inf.mpg.de/autocomplete-php/autocomplete/ajax.php"

  attr_accessor :params, :result

  def initialize
    @result = []

    @params = {
      :name => "dblpmirror",
      :path => "/dblp-mirror/",
      :page => "index.php",
      :log => "/var/opt/completesearch/log/completesearch.error_log",
      :qid => 6,
      :navigation_mode => "history",
      :language => "en",
      :mcsr => 40,
      :mcc => 0,
      :mcl => 80,
      :hpp => 20,
      :eph => 1,
      :er => 20,
      :dm => 3,
      :bnm => "R",
      :ll => 2,
      :mo => 100,
      :accc => ":",
      :syn => 0,
      :deb => 0,
      :hrd => "1a",
      :hrw => "1d",
      :qi => 1,
      :fh => 1,
      :fhs => 1,
      :mcs => 20,
      :rid => 0,
      :qt => "H"
    }

  end


  def query(what, to_json = false)

    # Make some simple means of caching
    return if @params["query"] == what

    @params["query"] = what

    url = URI.parse(BASE_URI)
    req = Net::HTTP::Post.new(url.path)

    req.set_form_data(@params)
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      # OK
      body = extreact_from_body(res.body)
      parse_table(body)
      @result = parse_table(body)

      if to_json
        return @result.to_json
      end

      @result
    else
      res.error!
    end

  end


  def extreact_from_body(body)
    raw = body.split("\n")[27][11..-2].gsub("'", "\"")
    full = JSON.parse(raw)
    full["body"]
  end
  
  def parse_table(body)
    result = []

    body.scan(/<tr>(.*?)<\/tr>/m) do |match|
      
      cells = match[0].scan(/<td.*?>(.*?)<\/td>/m)
      next unless cells.size == 3
      
      obj = {}
      # First Cell is the cite key
      obj['cite'] = "DBLP:" << cells[0][0].match(/href="http:\/\/dblp\.uni-trier\.de\/rec\/bibtex\/(.*?)">/)[1]

      # second cell the link to the electronic version

      # Third cell is author + title
      obj['title'] = cells[2][0].gsub(/<.*?>/,"")

      result << obj
    end
    result
  end

  # Based on the last result that was fetched, a new cite key is returned
  # based on the position inside the result.
  def select(num)
    return if @result.size == 0 || @result.size < num
    return @result[num.abs][:cite]
  end

  def present
    @result.each_with_index do |item, i|
      puts "\t#{i+1}\t#{item[:title]}\n"
    end
  end

  def cite(num)
    "\\cite{#{select(num)}}"
  end



end


if ARGV.size > 0
  q = DBLPQuery.new
  result = q.query("Hyrise")
  puts result
else

  input_text = `CocoaDialog inputbox --title "DBLP" --informative-text "Query" --button1 "OK" --button2 "Cancel"`
  splitted = input_text.split("\n")
  
  TextMate.exit_discard() unless splitted[0] == "1"

  q = DBLPQuery.new
  result = q.query(splitted[1])
  TextMate.exit_show_tool_tip( "No papers found ") if result.empty?

  plist = { 'menuItems' => result }.to_plist
  res = OSX::PropertyList::load(`"$DIALOG" -up #{e_sh plist}`)

  TextMate.exit_discard() unless res.has_key? 'selectedMenuItem'

  # final touches
  print( "\\cite{#{res['selectedMenuItem']['cite']}} ")

end
