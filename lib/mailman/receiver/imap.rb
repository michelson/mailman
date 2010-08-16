require 'net/imap'

# add plain as an authentication type...
# This is taken from:
# http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/lib/net/imap.rb?revision=7657&view=markup&pathrev=10966

# Authenticator for the "PLAIN" authentication type.  See
# #authenticate().
class PlainAuthenticator
  def process(data)
    return "\0#{@user}\0#{@password}"
  end

  private

  def initialize(user, password)
    @user = user
    @password = password
  end
end

Net::IMAP.add_authenticator "PLAIN", PlainAuthenticator

module Mailman
  class Receiver
    # Receives messages using IMAP, and passes them to a {MessageProcessor}.
    class IMAP

      # @return [Net::IMAP] the IMAP connection
      attr_reader :connection

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [String] :server the server to connect to
      # @option options [Integer] :port the port to connect to
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      # @options options [Boolean] :use_login
      # @options options [String] :processed_folder
      # @options options [String] :error_folder
      # @options options [Boolean] :ssl 
      def initialize(options)
        
        @processor = options[:processor]
        @authentication = options[:authentication] || 'PLAIN'
        @username = options[:username]
        @password = options[:password]
        @port = options[:port] || 993
        
        @use_login = options[:use_login]
        @processed_folder = options[:processed_folder]
        @error_folder = options[:error_folder] || 'bogus'
        
        @ssl = options[:ssl] ||= false
        @connection = Net::IMAP.new(options[:server], @port , @ssl )
        
      end

      # Connects to the IMAP server.
      def connect
         if @use_login
            @connection.login(@username, @password)
          else
            @connection.authenticate(@authentication, @username, @password)
          end
      end

      # Disconnects from the IMAP server.  # Delete messages and log out
      def disconnect
        @connection.logout
       # @connection.disconnect
      end
      
      def expunge
        @connection.expunge 
      end

      # Iterates through new messages, passing them to the processor, and
      # moving it to the processed or bogus folder.
      
      def get_messages
        @connection.select('INBOX')
        @connection.uid_search(['ALL']).each do |uid|
          msg = @connection.uid_fetch(uid,'RFC822').first.attr['RFC822']
          
          @processor.process(msg)
          
          begin
            process_message(msg)
            add_to_processed_folder(uid) if @processed_folder
          rescue
            handle_bogus_message(msg)
          end
          puts msg.to_json
          
          # Mark message as deleted 
          @connection.uid_store(uid, "+FLAGS", [:Seen, :Deleted])
        end
      end 
      
      # Store the message for inspection if the receiver errors
      def handle_bogus_message(message)
      create_mailbox(@error_folder)
      @connection.append(@error_folder, message)
    end

      def add_to_processed_folder(uid)
      create_mailbox(@processed_folder)
      @connection.uid_copy(uid, @processed_folder)
    end

      def create_mailbox(mailbox)
      unless @connection.list("", mailbox)
        @connection.create(mailbox)
      end
    end

    end
  end
end
