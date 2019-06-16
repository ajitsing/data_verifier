project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/data_verifier/**/*.rb', &method(:require))
