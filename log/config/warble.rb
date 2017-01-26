#java -Dwarbler.port=5000 -Dwarbler.host=127.0.0.1 -jar eidGateway.war
Warbler::Config.new do |config|
  config.features = %w(executable)
  config.dirs = %w(app config lib log)
  config.java_libs += FileList["lib/java/*.jar"]
  config.jar_name = "eidGateway"
end