require File.join(File.dirname(__FILE__), "rails", "controller")
require File.join(File.dirname(__FILE__), "rails", "view")

module Lockdown
  module Frameworks
    module Rails
      class << self
        def use_me?
          Object.const_defined?("ActionController") && ActionController.const_defined?("Base")
        end

        def included(mod)
          mod.extend Lockdown::Frameworks::Rails::Environment
          mixin
        end
        
        def mixin
          mixin_controller

          Lockdown.view_helper.class_eval do
            include Lockdown::Frameworks::Rails::View
          end

          Lockdown::System.class_eval do 
            extend Lockdown::Frameworks::Rails::System
          end
        end

        def mixin_controller(klass = Lockdown.controller_parent)
          klass.class_eval do
            include Lockdown::Session
            include Lockdown::Frameworks::Rails::Controller::Lock
          end

          klass.helper_method :authorized?

          klass.hide_action(:set_current_user, :configure_lockdown, :check_request_authorization)

          klass.before_filter do |c|
            c.set_current_user
            c.configure_lockdown
            c.check_request_authorization
          end

          klass.filter_parameter_logging :password, :password_confirmation
      
          klass.rescue_from SecurityError, :with => proc{|e| access_denied(e)}
        end
      end # class block

      module Environment

        def project_root
          ::RAILS_ROOT
        end

        def init_file
          "#{project_root}/lib/lockdown/init.rb"
        end

        def controller_parent
          if ::Rails.env == "production"
            ApplicationController
          else
            ::ActionController::Base
          end
        end

        def view_helper
          ::ActionView::Base 
        end

        def controller_class_name(str)
          str = "#{str}Controller"
          if str.include?("__")
            str.split("__").collect{|p| Lockdown.camelize(p)}.join("::")
          else
            Lockdown.camelize(str)
          end
        end

        def fetch_controller_class(str)
          eval("::#{controller_class_name(str)}")
        end
      end

      module System
        include Lockdown::Frameworks::Rails::Controller

        def skip_sync?
          Lockdown::System.fetch(:skip_db_sync_in).include?(ENV['RAILS_ENV'])
        end
      end # System
    end # Rails
  end # Frameworks
end # Lockdown
