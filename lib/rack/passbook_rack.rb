module Rack
  class PassbookRack

    def initialize(app)
    end

    def call(env)
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
            return {'method' => 'device_register_delete',
              'params' => {'deviceLibraryIdentifier' => parsed_path[url_beginning + 2],
                'passTypeIdentifier' => parsed_path[url_beginning + 4],
                'serialNumber' => parsed_path[url_beginning + 5]}}
          elsif args_length == 5
            return {'method' => 'passes_for_device',
              'params' => {'deviceLibraryIdentifier' => parsed_path[url_beginning + 2],
                'passTypeIdentifier' => parsed_path[url_beginning + 4]}}
          end
        end
      end

      return nil       
    end
  end
end

