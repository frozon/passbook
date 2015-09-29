module Passbook
  class PushNotification
    def self.send_notification(device_token)
      pusher = Grocer.pusher({:certificate => Passbook.notification_cert, :passphrase => Passbook.notification_passphrase || "", :gateway => Passbook.notification_gateway})
      notification = Grocer::PassbookNotification.new(:device_token => device_token)

      pusher.push notification
    end
  end
end
