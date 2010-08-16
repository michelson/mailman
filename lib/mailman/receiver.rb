module Mailman
  class Receiver

    autoload :POP3, 'mailman/receiver/pop3'
    autoload :IMAP, 'mailman/receiver/imap'

  end
end
