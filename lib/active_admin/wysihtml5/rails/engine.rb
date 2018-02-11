module ActiveAdmin
  module Wysihtml5
    module Rails
      class Engine < ::Rails::Engine
        engine_name 'activeadmin_wysihtml5'

        initializer 'precompile hook', group: :all do |app|
          app.config.assets.precompile += [
            'activeadmin-wysihtml5/base.js',
            'activeadmin-wysihtml5/base.css',
            'activeadmin-wysihtml5/wysiwyg.css'
          ]
        end
      end
    end
  end
end
