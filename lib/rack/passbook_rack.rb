module Rack
  class PassbookRack

    def initialize(app)
      @app = app
    end

    def call(env)
      method_and_params = find_method env['PATH_INFO']
      if method_and_params
        case method_and_params[:method]
        when 'device_register_delete'
          if env['REQUEST_METHOD'] == 'POST'
            posted_params = JSON.parse(env['rack.input'].read 1000)
            response = Passbook::PassbookNotification.register_pass(method_and_params[:params].merge! posted_params)
            [response[:status], {}, ['']]
          elsif env['REQUEST_METHOD'] == 'DELETE'
            response = Passbook::PassbookNotification.unregister_pass(method_and_params[:params])
            [response[:status], {}, {}]
          end
        when 'passes_for_device'
          response = Passbook::PassbookNotification.passes_for_device(method_and_params[:params])
          [response ? 200 : 204, {}, [response.to_json]]
        when 'latest_pass'
          response = Passbook::PassbookNotification.latest_pass(method_and_params[:params])
          if response
            [200, {'Content-Type' => 'application/vnd.apple.pkpass', 
              'Content-Disposition' => 'attachment', 
              'filename' => "#{method_and_params[:params]['serialNumber']}.pkpass"}, [response]]
          else
            [204, {}, {}]
          end
        when 'log'
          Passbook::PassbookNotification.log JSON.parse(env['rack.input'].read 10000)
          [200, {}, {}]
        else
        end
      else
        @app.call env
      end
    end

    def append_parameter_separator url
    end

    def each(&block)
    end


    def find_method(path)
      parsed_path = path.split '/'
      url_beginning = parsed_path.index 'v1'
      if url_beginning
        args_length = parsed_path.size - url_beginning

        if  (parsed_path[url_beginning + 1 ] == 'devices') and
          (parsed_path[url_beginning + 3 ] == 'registrations')
          if args_length == 6
            return method_and_params_hash 'device_register_delete', path
          elsif args_length == 5
            return method_and_params_hash 'passes_for_device', path
          end
        elsif parsed_path[url_beginning + 1] == 'passes' and args_length == 4
          return method_and_params_hash 'latest_pass', path
        elsif parsed_path[url_beginning + 1] == 'log' and args_length == 2
          return {:method => 'log'}
        end
      end

      return nil       
    end

    private 

    def method_and_params_hash(method, path)
      parsed_path = path.split '/'
      url_beginning = parsed_path.index 'v1'
      if method == 'latest_pass'
        {:method => 'latest_pass',
          :params => {'passTypeIdentifier' => parsed_path[url_beginning + 2],
            'serialNumber' => parsed_path[url_beginning + 3]}}
      else 
        return_hash = {:method => method, :params => 
          {'deviceLibraryIdentifier' => parsed_path[url_beginning + 2], 
            'passTypeIdentifier' => parsed_path[url_beginning + 4]}}
        return_hash[:params]['serialNumber'] = parsed_path[url_beginning + 5] if 
          method == 'device_register_delete'
        return_hash
      end
    end


  end
end

