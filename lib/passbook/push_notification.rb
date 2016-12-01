module Passbook
  class PushNotification
    class << self
      def pusher
        @pusher ||= Grocer.pusher(
          :certificate => Passbook.notification_cert,
          :passphrase => Passbook.notification_passphrase || "",
          :gateway => Passbook.notification_gateway
        )
      end

      def send_notification(device_token)
        notification = Grocer::PassbookNotification.new(:device_token => device_token)

        pusher.push notification
      end
    end
  end
end
