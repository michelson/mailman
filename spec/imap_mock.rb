
class MockImapMail
  def initialize(rfc2822, number)
    @rfc2822 = rfc2822
    @number = number
  end

  def pop
    @rfc2822
  end

  def number
    @number
  end

  def to_s
    "#{number}: #{pop}"
  end
  
  def first
      puts json_fixture('example_imap').first
     json_fixture('example_imap').first
  end
  
  def attr
     @rfc2822
  end
  
  def json_fixture(*name)
     json = File.new( File.join(SPEC_ROOT, 'fixtures', "#{name}.json")  , 'r')
     parser = Yajl::Parser.new
     hash = parser.parse(json)
  end
  

  
  
end

class MockIMAP
  @@start = false
 
  def yaml_fixture(*name)
    YAML.load_file( File.join(SPEC_ROOT, 'fixtures', "#{name}.yml") ) 
  end
  
  def json_fixture(*name)
    json = File.new( File.join(SPEC_ROOT, 'fixtures', "#{name}.json")  , 'r')
    parser = Yajl::Parser.new
    hash = parser.parse(json)
  end
  
  def fixture(*name)
    File.open(File.join(SPEC_ROOT, 'fixtures', name) + '.eml').read
  end

  def initialize
    @@popmails = []
    2.times do |i|
     # @@popmails << MockImapMail.new(json_fixture('example_imap'), i)
      @@popmails << MockImapMail.new("To: test@example.com\r\nFrom: chunky@bacon.com\r\nSubject: Hello!\r\n\r\nemail message\r\ntest#{i.to_s}", i)
    end
  end
  
  attr_reader :attr


  def each_mail(*args)
    @@popmails.each do |popmail|
      yield popmail
    end
  end
  
  def uid_search(type)
    return @@popmails
  end
  
  def uid_fetch(uid, type)
    return @@popmails.first
  end
  
  def authenticate(*args)
    @@start = true
    block_given? ? yield(self) : self
  end
  
  def login(*args)
    @@start = true
    block_given? ? yield(self) : self
  end
  
  def select(*args)
    true
  end

  
  def logout
    @@start = false
    return true
  end

end

require 'net/imap'
class Net::IMAP
  def self.new(*args)
    MockIMAP.new
  end
end

=begin
class Array
  def attr
    m = MockIMAP.new
    return m.uid_search("fake").first
    
  end
end
=end

