# frozen_string_literal: true

module ::DiscourseSaas
  class Engine < ::Rails::Engine
    engine_name DiscourseSaas::PLUGIN_NAME
    isolate_namespace DiscourseSaas
  end
end
