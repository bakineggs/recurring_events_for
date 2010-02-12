require 'pg'

begin
  $db_conn = PGconn.open(:dbname => 'recurring_events_test')

  $db_conn.exec 'SET TIMEZONE TO UTC;'
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../events.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../days_in_month.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../interval_for.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../intervals_between.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../generate_recurrences.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../recurrences_for.sql')
  $db_conn.exec File.read(File.dirname(__FILE__) + '/../recurring_events_for.sql')
rescue PGError
  puts "Failed to connect to and initialize database"
  raise
end

def executing(statements)
  $db_conn.exec "BEGIN"
  results = []
  begin
    [statements].flatten.each do |statement|
      $db_conn.query(statement).each do |result|
        results.push(result.values)
      end.clear
    end
  ensure
    $db_conn.exec "ROLLBACK"
  end
  results
end
