require "exception_notification"
require "socket"
ExceptionNotification::Notifier.exception_recipients = ["brianb@endpoint.com"]
ExceptionNotification::Notifier.email_prefix = "[#{Socket.gethostname} Error] "
ExceptionNotification::Notifier.sender_address = ["noreply@csinitiative.com"]
