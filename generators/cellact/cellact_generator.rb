class CellactGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  
  def manifest
    record do |m|
      unless options[:skip_migration]
        m.migration_template "migration.rb", 'db/migrate',
                             :migration_file_name => "create_cellact_logs"
      end
      m.file('app/models/cellact_log.rb', 'app/models/cellact_log.rb')
    end
  end
  
protected

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", "Don't generate a migration") { |v| options[:skip_migration] = v }
  end
  
end
