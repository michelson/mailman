require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))


  file = File.join(File.dirname(__FILE__), '..', '..', '..', "config_files/imap_credentials.yml")

  if YAML.load_file( file )
    begin YAML.load_file( file )
    IMAP_CREDENTIALS = YAML.load_file( file )
    puts IMAP_CREDENTIALS.to_yaml
   rescue => e
     puts "WARNING! loading config file imap_credentials.yml!!!!!!! , #{e}"
   end
  end


describe Mailman::Receiver::IMAP do

  before do
    @processor = mock('Message Processor', :process => true)
    @receiver_options = { :server => "#{IMAP_CREDENTIALS['server']}",
                          :username => "#{IMAP_CREDENTIALS['username']}",
                          :password => "#{IMAP_CREDENTIALS['password']}",
                          :ssl => true,
                          :use_login => true,
                          :port => 993,
                          :processed_folder => "processed",
                          :error_forder => "errors",
                          :processor => @processor
                        }
                        
                  
    @receiver = Mailman::Receiver::IMAP.new(@receiver_options)
    
  end

  describe 'connection' do

    it 'should connect to a IMAP server' do
      @receiver.connect.should be_true
    end

    it 'should disconnect from a IMAP server' do
      @receiver.connect
      @receiver.disconnect.should be_true
    end
  end
  
  describe "message reception" do 
    before do
      @receiver.connect
    end
    
    it 'should get messages and process them' do
      @processor.should_receive(:process).twice.with(/test/)
      @receiver.get_messages
    end
    
    it 'should delete the messages after processing' do
      @receiver.get_messages
      
      @connection.select('INBOX')
      @connection.uid_search(['ALL']).should be_empty
      
    end
    
  end

end
