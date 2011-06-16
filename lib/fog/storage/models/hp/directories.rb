require 'fog/core/collection'
require 'fog/storage/models/hp/directory'

module Fog
  module HP
    class Storage

      class Directories < Fog::Collection

        model Fog::HP::Storage::Directory

        def all
          data = connection.get_containers.body
          load(data)
        end

        def get(key, options = {})
          data = connection.get_container(key, options)
          directory = new(:key => key)
          for key, value in data.headers
            if ['X-Container-Bytes-Used', 'X-Container-Object-Count'].include?(key)
              directory.merge_attributes(key => value)
            end
          end
          directory.files.merge_attributes(options)
          directory.files.instance_variable_set(:@loaded, true)
          data.body.each do |file|
            directory.files << directory.files.new(file)
          end
          directory
        rescue Fog::HP::Storage::NotFound
          nil
        end

      end

    end
  end
end
