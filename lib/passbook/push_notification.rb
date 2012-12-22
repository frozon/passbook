module Passbook
  class PushNotification
    def self.send_notification(device_token)
      pusher = Grocer.pusher({:certificate => Passbook.notification_cert, :gateway => Passbook.notification_gateway})
      notification = Grocer::Notification.new(:device_token => device_token)

      def notification.validate_payload
      end

      pusher.push notification
    end
  end
end
