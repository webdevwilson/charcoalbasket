module Sugar
  module ActionController
    def flash_message(klass, message)
      message = "#{controller_name}.messages.#{message}" if message.is_a?(Symbol)
      flash[klass] = t(message)
    end
  end
end

